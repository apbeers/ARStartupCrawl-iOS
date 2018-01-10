//
//  DetailInterfaceController.swift
//  watch Extension
//
//  Created by Andrew Beers on 1/9/18.
//  Copyright © 2018 Andrew Beers. All rights reserved.
//

import WatchKit

class DetailInterfaceController: WKInterfaceController {

    @IBOutlet var TitleLabel: WKInterfaceLabel!
    @IBOutlet var DescriptionLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let announcement = context as? Announcement else {
            return
        }
        
        TitleLabel.setText(announcement.title)
        DescriptionLabel.setText(announcement.desc)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
