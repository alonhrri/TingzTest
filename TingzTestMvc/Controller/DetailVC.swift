//
//  DetailVC.swift
//  TingzTestMvc
//
//  Created by Alon Harari on 06/05/2019.
//  Copyright © 2019 Alon Harari. All rights reserved.
//


//MARK: - Frameworks
import Foundation
import UIKit
import CoreData
//MARK: - Class
class DetailVC: UIViewController {
    
    
    
    //MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    //MARK: - Properties of class
    var movie: Movie!
    
    
    
    //MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Movie Details"
        setupView()
    }
    // MARK: - Private methods
    
    fileprivate func setupView() {
        
        if let title = movie.title {
            self.titleLabel.text = title
        }
        self.ratingLabel.text = "Rating: \(String(movie.rating))"
        self.yearLabel.text = "Release Year: \(String(movie.releaseYear))"
        if let url = movie.image {
            self.photoImageView.loadImageUsingCacheWithURLString(url, placeHolder: UIImage(named: "placeholder"))
        }
        
        if movie.genre?.count != 0 {
            var str = "Genre:"
            for item in (movie?.genre)!{
                str += " \(item),"
            }
            self.genreLabel.text = str
        }
    }
    
    
}
