//
//  DistanceInterfaceController.swift
//  
//
//  Created by Andrew Beers on 1/9/18.
//

import WatchKit
import MapKit

class DistanceInterfaceController: WKInterfaceController {

    @IBOutlet var TitleLabel: WKInterfaceLabel!
    @IBOutlet var DistanceLabel: WKInterfaceLabel!
    @IBOutlet var DirectionLabel: WKInterfaceLabel!
    @IBOutlet var RoadNameLabel: WKInterfaceLabel!
    @IBOutlet var EnableLocationButton: WKInterfaceButton!
    @IBOutlet var DirectionsButton: WKInterfaceButton!
    
    var startup: Startup!
    let dataManager = DataManager.sharedInstance
    let locationManager = CLLocationManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        startup = context as? Startup
        
        TitleLabel.setText(startup.title)
        if startup.distance == 0 {
            DistanceLabel.setText("")
        } else {
            
            var distanceMiles = round((startup.distance/0.014472) * 100) / 100
            
            if distanceMiles < 0 {
                distanceMiles = distanceMiles * -1
            }
            
            if distanceMiles > 99 {
                distanceMiles = Double.infinity
            }
            DistanceLabel.setText(String(distanceMiles) + " mi")
        }
        DirectionLabel.setText(startup.direction)
        RoadNameLabel.setText(startup.nearestRoad)
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            EnableLocationButton.setHidden(true)
        } else {
            EnableLocationButton.setHidden(false)
        }
        
        NotificationCenter.default.addObserver(forName: .LocationPermissionsApproved, object: nil, queue: OperationQueue.main) { _ in
            
            self.EnableLocationButton.setHidden(true)
            
            for s in self.dataManager.getStartups() {
                if self.startup.id == s.id {
                    
                    var distanceMiles = round((s.distance/0.014472) * 100) / 100
                    
                    if distanceMiles < 0 {
                        distanceMiles = distanceMiles * -1
                    }
                    
                    if distanceMiles > 99 {
                        distanceMiles = Double.infinity
                    }
                    
                    self.DistanceLabel.setText(String(distanceMiles) + " mi")
                    self.DirectionLabel.setText(s.direction)
                    self.RoadNameLabel.setText(s.nearestRoad)
                }
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func EnableLocationButtonTapped() {
        
        locationTrigger = LocationTriggerInterface.DistanceInterfaceController
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func TappedDirectionsButton() {
        
        let coordinate = CLLocationCoordinate2D(latitude: startup.latitude, longitude: startup.longitude)
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        
        mapItem.name = startup.title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }
}
