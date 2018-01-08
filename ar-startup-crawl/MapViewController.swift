//
//  MapViewController
//  AR Startup Crawl
//
//  Created by Andrew Beers on 10/26/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import Firebase
import FirebaseDatabase
import CoreData

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let position = CLLocationCoordinate2D(latitude: 36.063610, longitude: -94.162561)
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        guard let mapEntity = NSEntityDescription.entity(forEntityName: Constants.CoreData.MapEntityName , in: context) else {
            return
        }
        
        ref.child("map").observe(.value, with: { (snapshot) in
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.MapEntityName)
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed")
            }
            
            guard let values = snapshot.value as? NSDictionary else {
                return
            }
            
            let enumerator = values.objectEnumerator()
            while let map = enumerator.nextObject() as? NSDictionary {
                
                guard let latitude: Double = map["latitude"] as? Double,
                    let longitude: Double = map["longitude"] as? Double,
                    let zoom: Double = map["zoom"] as? Double,
                    let style: String = map["style"] as? String
                    else {
                        return
                }
                
                let newMap = NSManagedObject(entity: mapEntity, insertInto: context)
                
                newMap.setValue(latitude, forKey: "latitude")
                newMap.setValue(longitude, forKey: "longitude")
                newMap.setValue(zoom, forKey: "zoom")
                newMap.setValue(style, forKey: "style")
                
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        guard let startupsEntity = NSEntityDescription.entity(forEntityName: Constants.CoreData.StartupsEntityName, in: context) else {
            return
        }
        
        ref.child("startups").observe(.value, with: { (snapshot) in
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.StartupsEntityName)
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed")
            }
            
            guard let values = snapshot.value as? NSDictionary else {
                return
            }
            
            let enumerator = values.objectEnumerator()
            while let startup = enumerator.nextObject() as? NSDictionary {
                
                guard let latitude: Double = startup["latitude"] as? Double,
                    let longitude: Double = startup["longitude"] as? Double,
                    let desc: String = startup["description"] as? String,
                    let logo: String = startup["logo"] as? String,
                    let logoBase64: String = startup["logoBase64"] as? String,
                    let snippet: String = startup["snippet"] as? String,
                    let url: String = startup["url"] as? String,
                    let title: String = startup["title"] as? String,
                    let id: Int = startup["id"] as? Int
                    else {
                        return
                }
                
                let newStartup = NSManagedObject(entity: startupsEntity, insertInto: context)
                
                newStartup.setValue(latitude, forKey: "latitude")
                newStartup.setValue(longitude, forKey: "longitude")
                newStartup.setValue(desc, forKey: "desc")
                newStartup.setValue(logo, forKey: "logo")
                newStartup.setValue(logoBase64, forKey: "logoBase64")
                newStartup.setValue(snippet, forKey: "snippet")
                newStartup.setValue(url, forKey: "url")
                newStartup.setValue(title, forKey: "title")
                newStartup.setValue(id, forKey: "id")
                
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: 36.063610, longitude: -94.162561, zoom: 15)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.isMyLocationEnabled = true
            }
        } else {
            print("Location services are not enabled")
        }
        
        mapView.settings.myLocationButton = true

        let screenSize = UIScreen.main.bounds
        let width = screenSize.width
        let height = screenSize.height
 
        mapView.frame = CGRect(x: 0.0, y: view.safeAreaInsets.top , width: width, height: height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)

        view = mapView
        
        NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main) { _ in
            
            self.refreshData()
        }
        self.refreshData()
    }

    func refreshData() {
  
        if mapView != nil {
            mapView.clear()
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let mapRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.MapEntityName)
        mapRequest.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(mapRequest)
            
            for data in result as! [NSManagedObject] {
                
                guard let latitude: Double = data.value(forKey: "latitude") as? Double,
                    let longitude: Double = data.value(forKey: "longitude") as? Double,
                    let style: String = data.value(forKey: "style") as? String,
                    let zoom: Float = data.value(forKey: "zoom") as? Float
                    else {
                        return
                }
                
                var trimmedStyle = style
                trimmedStyle = String(trimmedStyle.dropFirst(1))
                trimmedStyle = String(trimmedStyle.dropLast(1))
                do {
                self.mapView.mapStyle = try GMSMapStyle(jsonString: String(trimmedStyle))
                } catch {
                    print("Could not parse style")
                }
                
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let camera = GMSCameraPosition(target: location, zoom: zoom, bearing: CLLocationDirection(), viewingAngle: 0)
                
               // mapView.animate(to: camera)
            }
            
        } catch {
            print("Failed")
        }
        
        let startupsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.StartupsEntityName)
        //request.predicate = NSPredicate(format: "age = %@", "12")
        startupsRequest.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(startupsRequest)
            for data in result as! [NSManagedObject] {
                
                guard let snippet: String = data.value(forKey: "snippet") as? String,
                    let title: String = data.value(forKey: "title") as? String,
                    let latitude: Double = data.value(forKey: "latitude") as? Double,
                    let longitude: Double = data.value(forKey: "longitude") as? Double
                else {
                        return
                }
                
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                marker.title = title
                marker.snippet = snippet + "                                          Directrions▶"
                marker.icon = #imageLiteral(resourceName: "Yellow-map-marker.png")
                marker.map = self.mapView
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            
            guard let location = locationManager.location?.coordinate else { return }
            let camera = GMSCameraPosition(target: location, zoom: 17, bearing: CLLocationDirection(), viewingAngle: 0)
            
            mapView.animate(to: camera)
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        mapView.isMyLocationEnabled = true
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {

        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: marker.position, addressDictionary:nil))
        
        mapItem.name = marker.title
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: marker.title as NSObject? ?? "Invalid Title",
            AnalyticsParameterContentType: Constants.Analytics.DirectionsRequested as NSObject
            ])
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

