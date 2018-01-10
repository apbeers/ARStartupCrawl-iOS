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
    var direction: String
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
        
        location = locationManager.location?.coordinate
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
                
                self.startups.append(Startup(id: item["startup_id"].description, title: item["title"].description, brewery: item["snippet"].description, latitude: latitude, longitude: longitude, distance: 0, direction: "", nearestRoad: ""))
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
                startups[i].distance = startupLocation.distance(from: userLocation)
                
                let yDiff = userLocation.coordinate.latitude - startupLocation.coordinate.latitude
                let xDiff = userLocation.coordinate.longitude - startupLocation.coordinate.longitude
                let angle = atan2(yDiff, xDiff) * (180 / Double.pi)
                
                /*
 
                the startups are West of the user
                 1.23425614582588
                 0.99121817735051
                 1.14627456554782
                 0.972177571669565
                 1.06905467815322
                 1.16739709423345
                 1.20290043883435
                 1.19164002386384
 
                 the startups are North of the user
                 -87.7556369342647
                 -87.7255423299589
                 -87.7508099560592
                 -87.6101515487674
                 -87.6305539378423
                 -87.7439881669118
                 -87.7790152261104
                 -87.777484842513
 
                 the startups are East of the user
                 -179.852737754242
                 -179.699908885254
                 -179.797335923774
                 -179.689990240963
                 -179.751320752709
                 -179.810857824874
                 -179.832276574104
                 -179.82522484983
                 
                 the startups are South of the user
                 92.4614151016621
                 92.3305194118201
                 92.4408650023876
                 91.8219891685688
                 91.9132788197494
                 92.4109043972371
                 92.5637327675325
                 92.5571625573206
                */
                
                // -180 East -157.5 < angle < -180
                // -135 NE -157.5 < angle < -112.5
                // -90 North -112.5 < angle < -67.5
                // -45 NW -67.5 < angle < -22.5
                // 0  West -22.5 < angle < 22.5
                // 45 SW 22.5 < angle < 67.5
                // 90 South 67.5 < angle < 112.5
                // 135 SE 112.5 < angle < 157.5
                // 180 East 157.5 < angle < 180
                
                if -157.5 < angle && angle < -112.5 {
                    startups[i].direction = "NE"
                } else if -112.5 < angle && angle < -67.5 {
                    startups[i].direction = "N"
                } else if -67.5 < angle && angle < -22.5 {
                    startups[i].direction = "NW"
                } else if -22.5 < angle && angle < 22.5 {
                    startups[i].direction = "W"
                } else if 22.5 < angle && angle < 67.5 {
                    startups[i].direction = "SW"
                } else if 67.5 < angle && angle < 112.5 {
                    startups[i].direction = "S"
                } else if 112.5 < angle && angle < 157.5 {
                    startups[i].direction = "SE"
                } else if (-157.5 < angle && angle < -180) || (157.5 < angle && angle < 180) {
                    startups[i].direction = "E"
                } else {
                    startups[i].direction = "X"
                }
                print(startups[i].direction)
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
