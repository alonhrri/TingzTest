//
//  MovieVM.swift
//  TingzTestMvc
//
//  Created by Alon Harari on 06/05/2019.
//  Copyright © 2019 Alon Harari. All rights reserved.
//

import Foundation
import CoreData

class MovieVM : NSObject  {
    
    var movies = [Movie]()
    //MARK: - Core Data Methods
    //Fetch the Data
    func fetchData(completion:@escaping (String?,Bool,_ error:NSError?)->()){
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
            do {
                self.movies = try context.fetch(fetchRequest) as? [NSManagedObject] as! [Movie]
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    //MARK: - TableView methods


}


