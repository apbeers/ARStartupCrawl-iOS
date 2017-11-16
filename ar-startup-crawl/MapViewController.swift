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

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let position = CLLocationCoordinate2D(latitude: 36.063610, longitude: -94.162561)
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        ref.child("startups").observeSingleEvent(of: .value, with: { (snapshot) in
            self.mapView.clear()
            // Get user value
            guard let values = snapshot.value as? NSDictionary else {
                return
            }
            
            let enumerator = values.objectEnumerator()
            while let startup = enumerator.nextObject() as? NSDictionary {
                
                guard let latitude: Double = startup["latitude"] as? Double, let longitude: Double = startup["longitude"] as? Double else {
                    return
                }
                
                let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                guard let title: String = startup["title"] as? String, let snippet: String = startup["snippet"] as? String else {
                    return
                }
             
                let marker = GMSMarker(position: position)
                marker.title = title
                marker.snippet = snippet + "                                          Directrions▶"
                marker.icon = #imageLiteral(resourceName: "Yellow-map-marker.png")
                marker.map = self.mapView
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
 
        do {
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
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

