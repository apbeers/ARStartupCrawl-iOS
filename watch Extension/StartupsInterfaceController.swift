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

class StartupsInterfaceController: WKInterfaceController, WCSessionDelegate {

    var session: WCSession!
    
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
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        switch activationState {
        case WCSessionActivationState.activated:
            print("session activated")
        case WCSessionActivationState.notActivated:
            print("session not activated")
        default:
            print("default case")
        }
        
        session.sendMessage(["request", "startup_details"], replyHandler: { response in
            print("reponse: \(response)")
        }, errorHandler: { error in
            print("error: \(error)")
        })
        
    }
}
