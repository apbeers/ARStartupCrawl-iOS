//
//  AppDelegate.swift
//  ar-startup-crawl
//
//  Created by Andrew Beers on 11/16/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//
import UIKit
import GoogleMaps
import Firebase
import UserNotifications
import FirebaseMessaging
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var ref: DatabaseReference!
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("AIzaSyDPJJiHZXPz1OW2ihD_WEIkOaF63a6s3IE")
        UIApplication.shared.registerForRemoteNotifications()
        FirebaseApp.configure()
        
        ref = Database.database().reference()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        let context = self.persistentContainer.viewContext
        
        
        
        
        
        
        
        guard let mapEntity = NSEntityDescription.entity(forEntityName: Constants.CoreData.MapEntityName , in: context) else {
            return true
        }
        
        ref.child("map").observe(.value, with: { (snapshot) in
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.MapEntityName)
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed")
            }
            
            guard let values = snapshot.value as? NSDictionary else {
                return
            }
            
            let enumerator = values.objectEnumerator()
            while let map = enumerator.nextObject() as? NSDictionary {
                
                
                guard let latitude: Double = map["latitude"] as? Double,
                    let longitude: Double = map["longitude"] as? Double,
                    let zoom: Double = map["zoom"] as? Double,
                    let style: String = map["style"] as? String
                    else {
                        return
                }
                
                let newMap = NSManagedObject(entity: mapEntity, insertInto: context)
                
                newMap.setValue(latitude, forKey: "latitude")
                newMap.setValue(longitude, forKey: "longitude")
                newMap.setValue(zoom, forKey: "zoom")
                newMap.setValue(style, forKey: "style")
                
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
            
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
 
        
        guard let startupsEntity = NSEntityDescription.entity(forEntityName: Constants.CoreData.StartupsEntityName, in: context) else {
            return true
        }
        
        ref.child("startups").observe(.value, with: { (snapshot) in
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.StartupsEntityName)
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(batchDeleteRequest)
            } catch {
                print("Failed")
            }
            
            guard let values = snapshot.value as? NSDictionary else {
                return
            }
            
            let enumerator = values.objectEnumerator()
            while let startup = enumerator.nextObject() as? NSDictionary {
                
                guard let latitude: Double = startup["latitude"] as? Double,
                    let longitude: Double = startup["longitude"] as? Double,
                    let desc: String = startup["description"] as? String,
                    let logo: String = startup["logo"] as? String,
                    let logoBase64: String = startup["logoBase64"] as? String,
                    let snippet: String = startup["snippet"] as? String,
                    let url: String = startup["url"] as? String,
                    let title: String = startup["title"] as? String,
                    let id: Int = startup["id"] as? Int
                else {
                    return
                }
                
                let newStartup = NSManagedObject(entity: startupsEntity, insertInto: context)
                
                newStartup.setValue(latitude, forKey: "latitude")
                newStartup.setValue(longitude, forKey: "longitude")
                newStartup.setValue(desc, forKey: "desc")
                newStartup.setValue(logo, forKey: "logo")
                newStartup.setValue(logoBase64, forKey: "logoBase64")
                newStartup.setValue(snippet, forKey: "snippet")
                newStartup.setValue(url, forKey: "url")
                newStartup.setValue(title, forKey: "title")
                newStartup.setValue(id, forKey: "id")
                
                do {
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
      //  print(userInfo)
        
        /*
        guard let aps = userInfo[AnyHashable("aps")] as? NSDictionary else {
            return
        }
        guard let alert = aps["alert"] as? NSDictionary else {
            return
        }


        let context = self.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.CoreData.AnnouncementsEntityName, in: context) else {
            return
        }
        
        let newAnnouncement = NSManagedObject(entity: entity, insertInto: context)
        
        guard
            let body = alert["body"] as? String,
            let title = alert["title"] as? String
            else {
                // handle any error here
                return
        }
        newAnnouncement.setValue(title, forKey: "title")
        newAnnouncement.setValue(body, forKey: "body")
        newAnnouncement.setValue(Date(), forKey: "date")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
            */
        completionHandler(UIBackgroundFetchResult.newData)
 
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: Constants.CoreData.ModelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
    
}
