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
import SwiftyJSON
import Alamofire

enum Sort: Int {
    case Startup
    case Brewery
    case Distance
}

//TODO: cut brewery names down to two words to fit on screen

class StartupsInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    var startups: [Startup] = []
    var currentSortType = Sort.Startup
    let dataManager = DataManager.sharedInstance
    let locationManager = CLLocationManager()
    var location: CLLocationCoordinate2D?
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var SortButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        SortButton.setEnabled(false)
        
        dataManager.refreshStartupsFromAPI()
        dataManager.refreshAnnouncementsFromAPI()
        
        NotificationCenter.default.addObserver(forName: .StartupsUpdated, object: nil, queue: OperationQueue.main) { _ in
            
            self.startups = self.dataManager.getStartups()
            self.sortTable()
        }
        SortButton.setTitle("Distance")
        
        location = locationManager.location?.coordinate
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            
            location = locationManager.location?.coordinate
            currentSortType = .Startup
            SortButtonTapped()
        }
    }
    
    @IBAction func SortButtonTapped() {
        
        switch currentSortType {
        case .Startup:
            if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                
                currentSortType = .Distance
                SortButton.setTitle("Brewery")
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        case .Distance:
            currentSortType = .Brewery
            SortButton.setTitle("Startup")
        case .Brewery:
            currentSortType = .Startup
            SortButton.setTitle("Distance")
        }

        sortTable()
    }
    
    func sortTable() {
        
        switch currentSortType {
        case .Startup:
            startups = startups.sorted(by: {$0.title < $1.title})
        case .Brewery:
            startups = startups.sorted(by: {$0.snippet < $1.snippet})
        case .Distance:
            
            guard let latitude = location?.latitude, let longitude = location?.longitude else {
                return
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
            
            startups = startups.sorted(by: {$0.distance < $1.distance})
        }
        
        SortButton.setEnabled(true)
        reloadTable()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locationManager.location?.coordinate
    }
    
    func reloadTable() {
        
        table.setNumberOfRows(startups.count, withRowType: "StartupRow")
        
        var index = 0
        for startup in startups {
            
            guard let row = table.rowController(at: index) as? StartupRow else {
                return
            }
            
            row.StartupLabel.setText(startup.title)
            row.BreweryLabel.setText(startup.snippet)
            
            index += 1
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        let coordinate = CLLocationCoordinate2D(latitude: startups[rowIndex].latitude, longitude: startups[rowIndex].longitude)
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        
        mapItem.name = startups[rowIndex].title
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
    }
}
