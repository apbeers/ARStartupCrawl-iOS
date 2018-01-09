//
//  StartupsInterfaceController.swift
//  watch Extension
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import MapKit

struct StartupData {
    let title: String
    let brewery: String
    let latitude: Double
    let longitude: Double
}

class StartupsInterfaceController: WKInterfaceController, WCSessionDelegate {

    var session: WCSession!
    var startups: [StartupData] = []
    @IBOutlet var table: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        session = WCSession.default
        session.delegate = self
        session.activate()
        reloadTable()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func reloadTable() {
        
        table.setNumberOfRows(startups.count, withRowType: "StartupRow")
        
        var index = 0
        for startup in startups {
            
            guard let row = table.rowController(at: index) as? StartupRow else {
                return
            }
            
            row.StartupLabel.setText(startup.title)
            row.BreweryLabel.setText(startup.brewery)
            
            index += 1
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        let coordinate = CLLocationCoordinate2D(latitude: startups[rowIndex].latitude, longitude: startups[rowIndex].longitude)
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        
        mapItem.name = startups[rowIndex].title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
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
        
        session.sendMessage(["request": "startup_details"], replyHandler: { response in
            print("reponse: \(response)")
            self.reloadTable()
        }, errorHandler: { error in
            print("error: \(error)")
        })
    }
    
    
}
