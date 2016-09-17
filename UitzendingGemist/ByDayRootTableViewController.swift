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
    fileprivate var loaded = false
    fileprivate var days = [(from: Date, to: Date, label: String, name: String)]() {
        didSet {
            tableView.reloadData()
        }
    }

    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // construct days
        days = NPOManager.sharedInstance.getDaysSinceNow(numberOfDays: 17)
        setupInitialUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: Initial load
    
    fileprivate func setupInitialUI() {
        guard days.count > 0 && tableView.indexPathsForSelectedRows == nil else {
            return
        }
        
        // mark as loaded
        loaded = true
        
        // get a random episode and use it to set the background
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
        updateDetailedView(forRow: 0)
    }
    
    //MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    // swiftlint:disable force_cast
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.Day.rawValue, for: indexPath) as! ByDayRootTableViewCell
        let day = days[(indexPath as NSIndexPath).row]
        if (indexPath as NSIndexPath).row > 2 {
            cell.configure(withName: day.name)
        } else {
            cell.configure(withName: day.label)
        }
        return cell
    }
    // swiftlint:enable force_cast
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateDetailedView(forRow: (indexPath as NSIndexPath).row)
    }
    
    fileprivate func updateDetailedView(forRow row: Int) {
        let day = days[row]
        
        guard let vcs = splitViewController?.viewControllers, vcs.count > 1, let vc = vcs[1] as? ByDayDetailedCollectionViewController else {
            return
        }
        
        vc.configure(withDate: day.from)
    }
}
