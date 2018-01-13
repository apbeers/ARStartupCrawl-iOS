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
import CoreData

enum LocationTriggerInterface: Int {
    case StartpsInterfaceController
    case DistanceInterfaceController
    case Invalid
}

var locationTrigger: LocationTriggerInterface?

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

   // private var startups: [Startup] = []
    private var session: WCSession!
    private let locationManager = CLLocationManager()
    private var location: CLLocationCoordinate2D?
    static let sharedInstance = DataManager()
    private let startupEntityName = "Startups"
    private let announcementEnitityName = "Announcements"
    
    private override init() {
        super.init()
        session = WCSession.default
        session.delegate = self
        session.activate()
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            
            location = manager.location?.coordinate
            NotificationCenter.default.post(name: .LocationPermissionsApproved, object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = manager.location?.coordinate
        NotificationCenter.default.post(name: .StartupsUpdated, object: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
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
            
            do {
                let json = try JSON(data: responseData)
                
                let context = DataKit.sharedInstance.persistentContainer.viewContext
                
                // Create Fetch Request
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.startupEntityName)
                
                // Create Batch Delete Request
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(batchDeleteRequest)
                } catch {
                    print("Failed")
                }
                
                guard let entity = NSEntityDescription.entity(forEntityName: self.startupEntityName, in: context) else {
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
                    newStartup.setValue(item["snippet"].description, forKey: "snippet")
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
                print("Invalid Startups JSON")
            }
        }
    }
    
    func getStartups() -> [Startup] {
        
        var startups: [Startup] = []
        
        let startupsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: startupEntityName)
        //request.predicate = NSPredicate(format: "age = %@", "12")
        startupsRequest.returnsObjectsAsFaults = false
        do {
            let result = try DataKit.sharedInstance.persistentContainer.viewContext.fetch(startupsRequest)
            for data in result as! [NSManagedObject] {
                
                guard let snippet: String = data.value(forKey: "snippet") as? String,
                    let title: String = data.value(forKey: "title") as? String,
                    let latitude: Double = data.value(forKey: "latitude") as? Double,
                    let longitude: Double = data.value(forKey: "longitude") as? Double,
                    let id: String = data.value(forKey: "id") as? String
                    else {
                        return startups
                }

                startups.append(Startup(id: id, title: title, brewery: snippet, latitude: latitude, longitude: longitude, distance: 0, direction: "", nearestRoad: ""))
                
            }
            
        } catch {
            print("Failed")
        }
        
        
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            guard let latitude = location?.latitude, let longitude = location?.longitude else {
                return startups
            }
 
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)

            for i in 0 ..< startups.count {

                let startupLocation = CLLocation(latitude: startups[i].latitude, longitude: startups[i].longitude)
                
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
                
                let distance: Double = startupLocation.distance(from: userLocation)
                
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
            
            do {
             
                let json = try JSON(data: responseData)
                
                let context = DataKit.sharedInstance.persistentContainer.viewContext
                
                // Create Fetch Request
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.announcementEnitityName)
                
                // Create Batch Delete Request
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(batchDeleteRequest)
                } catch {
                    print("Failed")
                }
                
                guard let entity = NSEntityDescription.entity(forEntityName: self.announcementEnitityName, in: context) else {
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
                
            } catch {
                print("Invalid Announcement JSON")
            }
        }
    }
    
    func getAnnouncements() -> [Announcement] {
        
        var announcements: [Announcement] = []
        let context = DataKit.sharedInstance.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Announcements")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                guard let title = data.value(forKey: "title") as? String ,let body = data.value(forKey: "body") as? String ,let date = data.value(forKey: "date") as? String else {
                    return announcements
                }
                announcements.append(Announcement(title: title, desc: body, datetime: date))
                
            }
        } catch {
            print("Failed")
        }
        return announcements
    }
}

extension Notification.Name {
    
    static let StartupsUpdated = Notification.Name("on-startups-updated")
    static let AnnouncementsUpdated = Notification.Name("on-announcements-updated")
    static let LocationPermissionsApproved = Notification.Name("on-location=permissions-approved")
}
