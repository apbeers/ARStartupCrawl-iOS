//
//  TabBarController.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 10/26/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        // Do any additional setup after loading the view.
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.title! {
        case "Map":
            UIApplication.shared.statusBarStyle = .lightContent
        case "Startups":
            UIApplication.shared.statusBarStyle = .default
        case "Announcements":
            UIApplication.shared.statusBarStyle = .default
            UIApplication.shared.applicationIconBadgeNumber = 0
        default:
            break
        }
        
        guard let title: String = item.title else {
            return
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: title as NSObject,
            AnalyticsParameterContentType: Constants.Analytics.TabSelected as NSObject
        ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
