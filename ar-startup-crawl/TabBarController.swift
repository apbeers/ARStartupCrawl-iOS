//
//  TabBarController.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 10/26/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import CoreData

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
            
            downloadAnnouncements()
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
    
    func downloadAnnouncements() {
        
        Alamofire.request("https://ar-startup-crawl.herokuapp.com/notifications/guest", encoding: JSONEncoding.default).responseJSON { response in
          //  print("Request: \(String(describing: response.request))")   // original url request
          //  print("Response: \(String(describing: response.response))") // http url response
          //  print("Result: \(response.result)")                         // response serialization result
            
            guard let responseData = response.data else {
                return
            }
            
            let json = JSON(data: responseData)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.AnnouncementsEntityName)
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed")
            }
            
            guard let entity = NSEntityDescription.entity(forEntityName: Constants.CoreData.AnnouncementsEntityName, in: context) else {
                return
            }
            
            for (_, item) in json {
                
                let newAnnouncement = NSManagedObject(entity: entity, insertInto: context)
                
                newAnnouncement.setValue(item["title"].description, forKey: "title")
                newAnnouncement.setValue(item["body"].description, forKey: "body")
                newAnnouncement.setValue(item["datetime"].description, forKey: "date")
                
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
