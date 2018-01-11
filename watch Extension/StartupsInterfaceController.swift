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

        SortButton.setHidden(true)
        
        dataManager.refreshStartupsFromAPI()
        dataManager.refreshAnnouncementsFromAPI()
        
        NotificationCenter.default.addObserver(forName: .StartupsUpdated, object: nil, queue: OperationQueue.main) { _ in
            
            self.reloadTable()
        }
        
        NotificationCenter.default.addObserver(forName: .LocationPermissionsApproved, object: nil, queue: OperationQueue.main) { _ in
            
            if locationTrigger == LocationTriggerInterface.StartpsInterfaceController {
                self.currentSortType = .Startup
                self.SortButtonTapped()
            }
        }
    
        SortButton.setTitle("Distance")
        reloadTable()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        reloadTable()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func SortButtonTapped() {
        
        switch currentSortType {
        case .Startup:
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                currentSortType = .Distance
                SortButton.setTitle("Brewery")
            } else {
                locationTrigger = LocationTriggerInterface.StartpsInterfaceController
                locationManager.requestWhenInUseAuthorization()
            }
        case .Distance:
            currentSortType = .Brewery
            SortButton.setTitle("Startup")
        case .Brewery:
            currentSortType = .Startup
            SortButton.setTitle("Distance")
        }

        reloadTable()
    }
    
    func reloadTable() {
        
        startups = dataManager.getStartups()
        
        if startups.count > 0 {
            SortButton.setHidden(false)
        }
        
        for i in 0 ..< startups.count {
            
            let words = startups[i].brewery.components(separatedBy: " ")
            startups[i].brewery = words[0] + " " + words[1]
        }
        
        switch currentSortType {
        case .Startup:
            startups = startups.sorted(by: {$0.title < $1.title})
        case .Brewery:
            startups = startups.sorted(by: {$0.brewery < $1.brewery})
        case .Distance:
            startups = startups.sorted(by: {$0.distance < $1.distance})
        }
        
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
        
        presentController(withName: "DistanceInterfaceController", context: startups[rowIndex])
    }
}
