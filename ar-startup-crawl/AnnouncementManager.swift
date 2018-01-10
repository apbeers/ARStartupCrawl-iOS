//
//  AnnouncementManager.swift
//  ar-startup-crawl
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import CoreData
import Alamofire
import SwiftyJSON

struct Announcement {
    var title: String
    var desc: String
    var datetime: String
}

class AnnouncementManager: NSObject {
    
    static let sharedInstance = AnnouncementManager()
    override private init() { }
    
    func fetchAnnouncementsAPI() {
        
        Alamofire.request("https://ar-startup-crawl.herokuapp.com/notifications/guest", encoding: JSONEncoding.default).responseJSON { response in

            guard let responseData = response.data else {
                return
            }
            
            let json = JSON(data: responseData)

            let context = DataKit.sharedInstance.persistentContainer.viewContext
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.AnnouncementsEntityName)
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed")
            }
            
            guard let entity = NSEntityDescription.entity(forEntityName: Constants.CoreData.AnnouncementsEntityName, in: context) else {
                return
            }
            
            for (_, item) in json {
                
                let newAnnouncement = NSManagedObject(entity: entity, insertInto: context)
                
                newAnnouncement.setValue(item["title"].description, forKey: "title")
                newAnnouncement.setValue(item["body"].description, forKey: "body")
                newAnnouncement.setValue(item["datetime"].description, forKey: "date")
                
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
            
            NotificationCenter.default.post(name: .AnnouncementsUpdated, object: nil)
        }
    }
    
    func fetchAnnouncementsLocal() -> [Announcement] {
        
        var announcements: [Announcement] = []
        let context = DataKit.sharedInstance.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Announcements")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                if let title = data.value(forKey: "title") as? String ,let body = data.value(forKey: "body") as? String ,let date = data.value(forKey: "date") as? String {
                    
                    announcements.append(Announcement(title: title, desc: body, datetime: date))
                }
            }
        } catch {
            print("Failed")
        }
        return announcements
    }
}
