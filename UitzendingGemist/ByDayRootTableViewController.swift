//
//  ByDayRootTableViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 01/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ByDayRootTableViewController: UITableViewController {
    private var loaded = false
    private var days = [(from: NSDate, to: NSDate, label: String, name: String)]() {
        didSet {
            tableView.reloadData()
        }
    }

    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // construct days
        days = NPOManager.sharedInstance.getDaysSinceNow(numberOfDays: 17)
        setupInitialUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: Initial load
    
    private func setupInitialUI() {
        guard days.count > 0 && tableView.indexPathsForSelectedRows == nil else {
            return
        }
        
        // mark as loaded
        loaded = true
        
        // get a random episode and use it to set the background
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        updateDetailedView(forRow: 0)
    }
    
    //MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    // swiftlint:disable force_cast
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCells.Day.rawValue, forIndexPath: indexPath) as! ByDayRootTableViewCell
        let day = days[indexPath.row]
        if indexPath.row > 2 {
            cell.configure(withName: day.name)
        } else {
            cell.configure(withName: day.label)
        }
        return cell
    }
    // swiftlint:enable force_cast
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        updateDetailedView(forRow: indexPath.row)
    }
    
    private func updateDetailedView(forRow row: Int) {
        let day = days[row]
        
        guard let vcs = splitViewController?.viewControllers where vcs.count > 1, let vc = vcs[1] as? ByDayDetailedCollectionViewController else {
            return
        }
        
        vc.configure(withDate: day.from)
    }
}
