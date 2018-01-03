//
//  UpdatesTableViewController.swift
//  AR Startup Crawl
//
//  Created by Andrew Beers on 11/14/17.
//  Copyright © 2017 Andrew Beers. All rights reserved.
//

import UIKit
import CoreData

class UpdatesTableViewController: UITableViewController {

    var updates: [[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextDidSave, object: nil, queue: OperationQueue.main) { _ in
            
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
        
        self.updates.removeAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Announcements")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                if let title = data.value(forKey: "title") as? String ,let body = data.value(forKey: "body") as? String ,let date = data.value(forKey: "date") as? Date {
                    
                    let dateString: String = date.toString(dateFormat: "dd-MM hh:mm")
                    self.updates.append([title, body, dateString])
                }
            }
        } catch {
            
            print("Failed")
        }
        
        self.updates.reverse()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "updateCellReuseIdentifier", for: indexPath) as? UpdateTableViewCell else {
            return UITableViewCell()
        }
        
        cell.TitleLabel.text = updates[indexPath.row][0]
        cell.DescriptionLabel.text = updates[indexPath.row][1]
        cell.DatetimeLabel.text = updates[indexPath.row][2]
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
