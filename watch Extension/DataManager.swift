//
//  DataManager.swift
//  watch Extension
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import Alamofire
import SwiftyJSON
import WatchConnectivity
import MapKit

struct Startup {
    var id: String
    var title: String
    var brewery: String
    var latitude: Double
    var longitude: Double
    var distance: Double
    var nearestRoad: String
}

struct Announcement {
    var title: String
    var desc: String
    var datetime: String
}

class DataManager: NSObject, WCSessionDelegate, CLLocationManagerDelegate {

    private var startups: [Startup] = []
    private var announcements: [Announcement] = []
    private var session: WCSession!
    private let locationManager = CLLocationManager()
    private var location: CLLocationCoordinate2D?
    static let sharedInstance = DataManager()
    
    private override init() {
        super.init()
        session = WCSession.default
        session.delegate = self
        session.activate()
        locationManager.delegate = self
        location = locationManager.location?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            
            location = locationManager.location?.coordinate
            NotificationCenter.default.post(name: .LocationPermissionsApproved, object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        NotificationCenter.default.post(name: .StartupsUpdated, object: nil)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        switch activationState {
        case WCSessionActivationState.activated:
            print("watch session activated")
        case WCSessionActivationState.notActivated:
            print("watch session not activated")
        default:
            print("watch default case")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        guard let messageString = message["request"] as? String else {
            return
        }
        
        switch messageString {
        case "startups_updated":
            refreshStartupsFromAPI()
        case "announcements_updated":
            refreshAnnouncementsFromAPI()
        default:
            print("Uknown Message")
        }
    }
    
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
                
                self.startups.append(Startup(id: item["startup_id"].description, title: item["title"].description, brewery: item["snippet"].description, latitude: latitude, longitude: longitude, distance: 0, nearestRoad: ""))
            }
            
            NotificationCenter.default.post(name: .StartupsUpdated, object: nil)
        }
    }
    
    func getStartups() -> [Startup] {
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        
            location = locationManager.location?.coordinate
            
            guard let latitude = location?.latitude, let longitude = location?.longitude else {
                return startups
            }
            
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            for i in 0 ..< startups.count {
                
                let startupLocation = CLLocation(latitude: startups[i].latitude, longitude: startups[i].longitude)
                
                var distance = startupLocation.distance(from: userLocation)
                
                if distance < 0 {
                    distance = distance * -1
                }
                
                startups[i].distance = distance
            }
        }
        
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
    static let LocationPermissionsApproved = Notification.Name("on-location=permissions-approved")
}
