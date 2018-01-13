//
//  AnnouncementsInterfaceController.swift
//  watch Extension
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import WatchKit
import WatchConnectivity
import EMTLoadingIndicator

class AnnouncementsInterfaceController: WKInterfaceController {

    var announcements: [Announcement] = []
    let dataManager = DataManager.sharedInstance
    var indicator: EMTLoadingIndicator!
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var LoadingIndicatorImage: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        indicator = EMTLoadingIndicator(interfaceController: self, interfaceImage: LoadingIndicatorImage, width: 40, height: 40, style: .line)
        
        dataManager.refreshAnnouncementsFromAPI()
        
        NotificationCenter.default.addObserver(forName: .AnnouncementsUpdated, object: nil, queue: OperationQueue.main) { _ in
            
            self.reloadTable()
        }
        self.reloadTable()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func reloadTable() {
        
        announcements = dataManager.getAnnouncements()
        
        if announcements.count > 0 {
            table.setHidden(false)
            LoadingIndicatorImage.setHidden(true)
            indicator.hide()
        } else {
            table.setHidden(true)
            LoadingIndicatorImage.setHidden(false)
            indicator.showWait()
        }
        
        table.setNumberOfRows(announcements.count, withRowType: "AnnouncementRow")
        
        var index = 0
        for announcement in announcements {
            
            guard let row = table.rowController(at: index) as? AnnouncementRow else {
                return
            }
            
            row.AnnouncementTitleLabel.setText(announcement.title)
            
            index += 1
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
       
        presentController(withName: "DetailInterfaceController", context: announcements[rowIndex])
    }
    
}
