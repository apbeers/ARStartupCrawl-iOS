//
//  WatchConnectivityHandler.swift
//  ar-startup-crawl
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import WatchConnectivity
import DataKit

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
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        guard let messageString = message["request"] as? String else {
            return
        }
        
        switch messageString {
        case "startup_details":
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: StartupManager.read(), options: JSONSerialization.WritingOptions.prettyPrinted)
                replyHandler(["startup_details": jsonData])
            } catch {
                replyHandler(["startup_details": ""])
            }
        case "announcement_details":
            replyHandler(["announcement_details": "heres_the_announcement_details"])
        default:
            replyHandler(["unknown request": "unknown request"])
        }
    }
}
