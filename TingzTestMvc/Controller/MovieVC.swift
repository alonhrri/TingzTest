//
//  ViewController.swift
//  TingzTestMvc
//
//  Created by Alon Harari on 06/05/2019.
//  Copyright © 2019 Alon Harari. All rights reserved.
//
//MARK: - Frameworks
import UIKit
import CoreData
import JGProgressHUD

//MARK: - Class
class MovieVC: UITableViewController {
    
    
    
    //MARK: - Properties of class
    
    private var viewModel = MovieVM()
    
    
    /*
     A lazy stored property is a property whose initial value is not calculated until the first time it is used
     NSFetchResultController
      -  We can use NSFetchResultController when we need fetching, inserting, updating and deleting in core data and we need to update user interface like UITableView and UICollectionView.
     -  Every time a insert, update or delete for a managed object model is performed in managed object context, NSFRC provides the delegate call backs.
     -  NSFRC provides a method performFetch() which returns array of NSManagedObject models. This array of NSManagedObject models works very well with UITableViewDelegate and UITableViewDataSource methods as a feed array.
     -  NSFRC only works with core data.
    */
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Movie.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "releaseYear", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    private let cellID = "cellID"
    //MARK: - ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        
        clearData()
        updateTableContent()
        
    }
    
    
    
    
    
    // MARK: - Private methods
    func updateTableContent(){
        
        do {
            try self.fetchedhResultController.performFetch()//performFetch()  returns array of NSManagedObject (rows)
        } catch let error  {
            self.hud.dismiss()
            print("ERROR: \(error)")
        }
        
        
        let service = APIService()
        let url = "https://api.androidhive.info/json/movies.json"
        service.getDataWithurl(url: url){ (result) in
            switch result {
            case .Success(let data):
                self.clearData()
                self.saveInCoreDataWith(array: data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    private func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext //use of a Singleton Class in Swift
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                //Use map to loop over a collection and apply the same operation to each element in the collection:
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext() //use of a Singleton Class in Swift
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    
    
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    /*
     NSManagedObject is a row...
     NSManagedObjectContext allows you to insert, save, and retrieve (using NSFetchRequest) NSManagedObjects from the database.”
    */
    private func createMovieEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let movieEntity = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: context) as? Movie {
            movieEntity.title = dictionary["title"] as? String
            movieEntity.image = dictionary["image"] as? String
            movieEntity.releaseYear = dictionary["releaseYear"] as? Int16 ?? 2019
            movieEntity.rating = dictionary["rating"] as! Double
            movieEntity.genre = dictionary["genre"] as? [String]
            return movieEntity
        }
        return nil
    }
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        //Use map to loop over a collection and apply the same operation to each element in the collection:
        _ = array.map{self.createMovieEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    
    
    
}


//MARK: - NSFetchedResults delegate Extension
extension MovieVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        self.hud.dismiss()
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    
}

//MARK: - TableView delegate Extension
extension MovieVC {
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MovieCell
        if let movie = fetchedhResultController.object(at: indexPath) as? Movie {
            //cell.setMovieCellWith(movie: movie)
            if let title = movie.title {
                cell.titleLabel.text = title
            }
            cell.yearLabel.text = String(movie.releaseYear)
            if let url = movie.image {
                cell.photoImageview.loadImageUsingCacheWithURLString(url, placeHolder: UIImage(named: "placeholder"))
            }
            cell.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width + 30 //60 = sum of labels height
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1) get the movie
        if let movie = fetchedhResultController.object(at: indexPath) as? Movie {
            //2) performSegue*(
            performSegue(withIdentifier: "toDetail", sender: movie)
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerHeight: CGFloat
        
        switch section {
        case 0:
            // hide the header
            headerHeight = CGFloat.leastNonzeroMagnitude
        default:
            headerHeight = 21
        }
        
        return headerHeight
    }
}

// MARK: - Navigation Delegate Extension
extension MovieVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let detailVC = segue.destination as? DetailVC {
                detailVC.movie = sender as? Movie
            }
        }
    }
}




