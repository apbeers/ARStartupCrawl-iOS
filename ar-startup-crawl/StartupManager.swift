//
//  StartupManager.swift
//  DataKit
//
//  Created by Andrew Beers on 1/8/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import CoreData
import Alamofire
import SwiftyJSON

struct Startup {
    var id: String!
    var title: String!
    var snippet: String!
    var desc: String!
    var latitude: Double!
    var longitude: Double!
    var logo: UIImage!
    var url: String!
}

class StartupManager: NSObject {

    private override init() { }
    static let sharedInstance = StartupManager()
    let entityName = "Startups"
    
    func fetchStartupsAPI() {
        
        Alamofire.request("https://ar-startup-crawl.herokuapp.com/startups", encoding: JSONEncoding.default).responseJSON { response in
            
            guard let responseData = response.data else {
                return
            }
            
            do {
                
                let json = try JSON(data: responseData)
                
                let context = DataKit.sharedInstance.persistentContainer.viewContext
                
                // Create Fetch Request
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
                
                // Create Batch Delete Request
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(batchDeleteRequest)
                } catch {
                    print("Failed")
                }
                
                guard let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) else {
                    return
                }
                
                for (_, item) in json {
                    
                    let newStartup = NSManagedObject(entity: entity, insertInto: context)
                    
                    guard let latitude: Double = Double(item["latitude"].description),
                        let longitude: Double = Double(item["longitude"].description) else {
                            return
                    }
                    
                    newStartup.setValue(latitude, forKey: "latitude")
                    newStartup.setValue(longitude, forKey: "longitude")
                    newStartup.setValue(item["description"].description, forKey: "desc")
                    newStartup.setValue(item["logobase64"].description, forKey: "logoBase64")
                    newStartup.setValue(item["snippet"].description, forKey: "snippet")
                    newStartup.setValue(item["url"].description, forKey: "url")
                    newStartup.setValue(item["title"].description, forKey: "title")
                    newStartup.setValue(item["startup_id"].description, forKey: "id")
                    
                    do {
                        try context.save()
                    } catch {
                        print("Failed saving")
                    }
                }
                
                NotificationCenter.default.post(name: .StartupsUpdated, object: nil)
                
            } catch {
                
            }
        }
    }
    
    func fetchStartupsLocal() -> [Startup] {
        
        var startups: [Startup] = []
        
        let startupsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //request.predicate = NSPredicate(format: "age = %@", "12")
        startupsRequest.returnsObjectsAsFaults = false
        do {
            let result = try DataKit.sharedInstance.persistentContainer.viewContext.fetch(startupsRequest)
            for data in result as! [NSManagedObject] {
                
                guard let snippet: String = data.value(forKey: "snippet") as? String,
                    let title: String = data.value(forKey: "title") as? String,
                    let latitude: Double = data.value(forKey: "latitude") as? Double,
                    let longitude: Double = data.value(forKey: "longitude") as? Double,
                    let desc: String = data.value(forKey: "desc") as? String,
                    let logoBase64: String = data.value(forKey: "logoBase64") as? String,
                    let url: String = data.value(forKey: "url") as? String,
                    let id: String = data.value(forKey: "id") as? String
                    else {
                        return startups
                }
                
                guard let imageData = Data(base64Encoded: logoBase64, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
                    return startups
                }
                
                guard let logo = UIImage(data: imageData) else {
                    return startups
                }
                
                startups.append(Startup(id: id, title: title, snippet: snippet, desc: desc, latitude: latitude, longitude: longitude, logo: logo, url: url))
            }
            
        } catch {
            print("Failed")
        }
        
        return startups
    }
}
