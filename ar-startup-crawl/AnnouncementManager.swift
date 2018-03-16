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
    
    func addAnnouncement(title: String, body: String) {
        
        let context = DataKit.sharedInstance.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.CoreData.AnnouncementsEntityName, in: context) else {
            return
        }

        let newAnnouncement = NSManagedObject(entity: entity, insertInto: context)
        
        newAnnouncement.setValue(title, forKey: "title")
        newAnnouncement.setValue(body, forKey: "body")
        newAnnouncement.setValue(Date(), forKey: "date")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
        NotificationCenter.default.post(name: .AnnouncementsUpdated, object: nil)
    }
    
    func fetchAnnouncementsLocal() -> [Announcement] {
        
        var announcements: [Announcement] = []
        let context = DataKit.sharedInstance.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Announcements")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                if let title = data.value(forKey: "title") as? String ,let body = data.value(forKey: "body") as? String ,let date = data.value(forKey: "date") as? Date {
                    
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "h:mm a"
                    formatter.amSymbol = "AM"
                    formatter.pmSymbol = "PM"
                    
                    let dateString = formatter.string(from: date)
                    
                    announcements.append(Announcement(title: title, desc: body, datetime: dateString))
                }
            }
        } catch {
            print("Failed")
        }
        
        if announcements.isEmpty {
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "AM"
            formatter.pmSymbol = "PM"
            
            let dateString = formatter.string(from: Date())
            
            announcements.append(Announcement(title: "Welcome!", desc: "Announcements will appear here when the event starts", datetime: dateString))
        }
        
        announcements.reverse()
        
        return announcements
    }
}
