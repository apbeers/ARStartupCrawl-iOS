//
//  StartupsTableViewController.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 10/27/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit
import Firebase

class StartupsTableViewController: UITableViewController, UITabBarControllerDelegate {

    var startups: [[String]] = []
    var startupsImages: [UIImage] = []
    let startupManager = StartupManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        
        let navBar = navigationController?.navigationBar
        navBar?.topItem?.title = "Startups"
    
        NotificationCenter.default.addObserver(forName: .StartupsUpdated, object: nil, queue: OperationQueue.main) { _ in
            
            self.refreshData()
        }
        self.refreshData()
    }
    
    func refreshData() {
        
        self.startups.removeAll()
        self.startupsImages.removeAll()
 
        for startup in startupManager.fetchStartupsLocal() {
            self.startups.append([startup.title, startup.desc, startup.url])
            self.startupsImages.append(startup.logo)
        }
        
        self.startups.reverse()
        self.startupsImages.reverse()
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return startups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "startupsCellReuseIdentifier", for: indexPath) as? StartupTableViewCell else {
            return UITableViewCell()
        }
        
        cell.LogoImageView.image = startupsImages[indexPath.row]
        cell.ShortDescriptionLabel.text = startups[indexPath.row][1]
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: startups[indexPath.row][0] as NSObject,
            AnalyticsParameterContentType: Constants.Analytics.StartupSelected as NSObject
            ])
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as? WebViewViewController
        
        guard let selectedRow: Int = tableView.indexPathForSelectedRow?.row else {
            return
        }
        
        destination?.address = startups[selectedRow][2]
    }
}
