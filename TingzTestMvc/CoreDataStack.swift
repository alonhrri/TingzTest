//
//  CoreDataStack.swift
//  TingzTestMvc
//
//  Created by Alon Harari on 06/05/2019.
//  Copyright © 2019 Alon Harari. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack: NSObject {

    // MARK: - Core Data stack
    /*
     Singleton is a design pattern which is very popular in development. Most of the developers are using this design pattern. This is very simple, common and easy to use in your project. It’s initialize your class instance single time only with static property and it will share your class instance globally.
     */
    static let sharedInstance = CoreDataStack()
    private override init() {}// Prevent clients from creating another instance.
    
    func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TingzTestMvc")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    

}
