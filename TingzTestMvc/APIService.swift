//
//  APIService.swift
//  TingzTestMvc
//
//  Created by Alon Harari on 06/05/2019.
//  Copyright © 2019 Alon Harari. All rights reserved.
//

//MARK: - Frameworks
import Foundation
//MARK: - Class
class APIService: NSObject {
    //MARK: - Properties of class
    
    enum Result <T>{
        case Success(T)
        case Error(String)
    }
    // MARK: - Private methods
    func getDataWithurl(url: String, completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        guard let url = URL(string: url) else { return completion(.Error("Invalid URL, we can't update your feed")) }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(error?.localizedDescription ?? "There are no records to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [[String: AnyObject]] {
                        completion(.Success(json))                    
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
            }.resume()
    }
}
