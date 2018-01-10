//
//  UpdatesTableViewController.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 11/14/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit

class UpdatesTableViewController: UITableViewController {

    var announcements: [Announcement] = []
    let announcementManager = AnnouncementManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: .AnnouncementsUpdated, object: nil, queue: OperationQueue.main) { _ in
            
            self.refreshData()
        }
        self.refreshData()
        tableView.separatorStyle = .none
        tableView.rowHeight = 200
        
        let navBar = navigationController?.navigationBar
        navBar?.topItem?.title = "Announcements"
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshData() {
        
        announcements = announcementManager.fetchAnnouncementsLocal()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "updateCellReuseIdentifier", for: indexPath) as? UpdateTableViewCell else {
            return UITableViewCell()
        }
        
        cell.TitleLabel.text = announcements[indexPath.row].title
        cell.DescriptionLabel.text = announcements[indexPath.row].desc
        cell.DatetimeLabel.text = announcements[indexPath.row].datetime
        cell.selectionStyle = .none
        
        return cell
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
