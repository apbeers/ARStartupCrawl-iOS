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
    @IBOutlet var DirectionsButton: WKInterfaceButton!
    
    var startup: Startup!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        startup = context as? Startup
        
        TitleLabel.setText(startup.title)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func TappedDirectionsButton() {
        
        let coordinate = CLLocationCoordinate2D(latitude: startup.latitude, longitude: startup.longitude)
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        
        mapItem.name = startup.title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
        
    }
}
