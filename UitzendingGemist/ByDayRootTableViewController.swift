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
    private var days = [(from: Date, to: Date, label: String, name: String)]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var date: Date?

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // construct days
        days = NPOManager.sharedInstance.getDaysSinceNow(numberOfDays: 17)
        date = days.first?.from
        
        // setup the ui
        setupInitialUI()
        
        // and select the first date
        updateDetailedView(forRow: 0)
        
        // observe when we are foregrounded
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func applicationWillEnterForeground() {
        guard let date = date else { return }
        
        // update days and ui
        days = NPOManager.sharedInstance.getDaysSinceNow(numberOfDays: 17)
        setupInitialUI()
        
        // find the matching row
        guard let day = days.enumerated().filter({ (_, element) -> Bool in return element.from == date }).first else {
            updateDetailedView(forRow: 0)
            return
        }
        
        // select the specific row
        let indexPath = IndexPath(row: day.offset, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        
        // update detailed view
        updateDetailedView(forRow: day.offset)
    }
    
    // MARK: Initial load
    
    private func setupInitialUI() {
        guard days.count > 0 && tableView.indexPathsForSelectedRows == nil else {
            return
        }
        
        // mark as loaded
        loaded = true
        
        // get a random episode and use it to set the background
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
    }
    
    // MARK: UITableViewDataSource
    
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
        let row = (indexPath as NSIndexPath).row
        date = days[row].from
        updateDetailedView(forRow: row)
    }
    
    private func updateDetailedView(forRow row: Int) {
        let day = days[row]
        
        guard let vcs = splitViewController?.viewControllers, vcs.count > 1, let vc = vcs[1] as? ByDayDetailedCollectionViewController else {
            return
        }
        
        vc.configure(withDate: day.from)
    }
}
