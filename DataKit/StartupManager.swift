//
//  StartupManager.swift
//  DataKit
//
//  Created by Andrew Beers on 1/8/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import CoreData


public class StartupManager: NSObject {
    
    static let entityName = "Startups"
    
    func refreshFromAPI() {
        
    }
    
    func create() {
        
    }
    
    public class func read() -> [Startup] {
        
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
                
                startups.append(Startup(id: id, title: title, snippet: snippet, desc: desc, latitude: latitude, longitude: longitude, logoBase64: logoBase64, url: url))
            }
            
        } catch {
            print("Failed")
        }
        
        return startups
    }
    
    func update() {
        
    }
    
    func delete() {
        
    }
}
