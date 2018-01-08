//
//  MapViewController
//  AR Startup Crawl
//
//  Created by Andrew Beers on 10/26/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import Firebase
import CoreData
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let position = CLLocationCoordinate2D(latitude: 36.063610, longitude: -94.162561)
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadStartups()
        
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
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }

        let screenSize = UIScreen.main.bounds
        let width = screenSize.width
        let height = screenSize.height
 
        mapView.frame = CGRect(x: 0.0, y: view.safeAreaInsets.top , width: width, height: height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)

        view = mapView
        
        NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main) { _ in
            
            self.refreshData()
        }
    }

    func refreshData() {
  
        if mapView != nil {
            mapView.clear()
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext
        
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
    
    func downloadStartups() {
        
        Alamofire.request("https://ar-startup-crawl.herokuapp.com/startups", encoding: JSONEncoding.default).responseJSON { response in

            guard let responseData = response.data else {
                return
            }
            
            let json = JSON(data: responseData)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.StartupsEntityName)
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed")
            }
            
            guard let entity = NSEntityDescription.entity(forEntityName: Constants.CoreData.StartupsEntityName, in: context) else {
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

