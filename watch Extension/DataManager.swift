//
//  DataManager.swift
//  watch Extension
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct Startup {
    var id: String
    var title: String
    var snippet: String
    var latitude: Double
    var longitude: Double
}

struct Announcement {
    var title: String
    var desc: String
    var datetime: String
}

class DataManager: NSObject {

    static let sharedInstance = DataManager()
    private override init() {}
    
    private var startups: [Startup] = []
    private var announcements: [Announcement] = []
    
    func refreshStartupsFromAPI() {
        
        Alamofire.request("https://ar-startup-crawl.herokuapp.com/startups/nopics", encoding: JSONEncoding.default).responseJSON { response in
            
            guard let responseData = response.data else {
                return
            }
            
            let json = JSON(data: responseData)
            
            self.startups.removeAll()
            
            for (_, item) in json {
                
                guard let latitude: Double = Double(item["latitude"].description),
                    let longitude: Double = Double(item["longitude"].description) else {
                        return
                }
                
                self.startups.append(Startup(id: item["startup_id"].description, title: item["title"].description, snippet: item["snippet"].description, latitude: latitude, longitude: longitude))
            }
            
            NotificationCenter.default.post(name: .StartupsUpdated, object: nil)
        }
    }
    
    func getStartups() -> [Startup] {
        return startups
    }
    
    func refreshAnnouncementsFromAPI() {
        
        Alamofire.request("https://ar-startup-crawl.herokuapp.com/notifications/guest", encoding: JSONEncoding.default).responseJSON { response in
            
            guard let responseData = response.data else {
                return
            }
            
            let json = JSON(data: responseData)
            
            self.announcements.removeAll()
            
            for (_, item) in json {
                
                self.announcements.append(Announcement(title: item["title"].description, desc: item["body"].description, datetime: item["datetime"].description))
            }
            
            NotificationCenter.default.post(name: .AnnouncementsUpdated, object: nil)
        }
    }
    
    func getAnnouncements() -> [Announcement] {
        return announcements
    }
}

extension Notification.Name {
    
    static let StartupsUpdated = Notification.Name("on-startups-updated")
    static let AnnouncementsUpdated = Notification.Name("on-announcements-updated")
}
