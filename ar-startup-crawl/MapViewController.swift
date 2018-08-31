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

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let position = CLLocationCoordinate2D(latitude: 36.063610, longitude: -94.162561)
    let startupManager = StartupManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startupManager.fetchStartupsAPI()

        mapView = GMSMapView()
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
        
        NotificationCenter.default.addObserver(forName: .StartupsUpdated, object: nil, queue: OperationQueue.main) { _ in
            
            self.refreshData()
        }
        self.refreshData()
    }

    func refreshData() {
  
        if mapView != nil {
            mapView.clear()
        }
        
        let startups = startupManager.fetchStartupsLocal()
        
        var bounds = GMSCoordinateBounds()
        
        for startup in startups {
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: startup.latitude, longitude: startup.longitude))
            marker.title = startup.title
            marker.snippet = startup.snippet + "                                                                                                                     Tap For Directrions▶"
            marker.icon = UIImage(named: "yellow_map_marker.png")
            marker.map = self.mapView
            
            bounds = bounds.includingCoordinate(marker.position)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 80)
            mapView.animate(with: update)
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

