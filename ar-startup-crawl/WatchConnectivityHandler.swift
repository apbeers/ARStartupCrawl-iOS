//
//  WatchConnectivityHandler.swift
//  ar-startup-crawl
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import WatchConnectivity
import DataKit
import SwiftyJSON

class WatchConnectivityHandler: NSObject, WCSessionDelegate {
    
    var session = WCSession.default
    
    override init() {
        super.init()
        
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        switch activationState {
        case WCSessionActivationState.activated:
            print("iphone session activated")
        case WCSessionActivationState.notActivated:
            print("iphone session not activated")
        default:
            print("iphone default case")
        }
    }
    
    func startupsUpdated() {
        
    }
    
    func announcementsUpdated() {
        session.sendMessage(["request": "announcements_updated"], replyHandler: { reply in
            
        }, errorHandler: { error in
            
        })
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
