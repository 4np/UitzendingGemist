//
//  ProgramRootTableViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 26/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ProgramRootTableViewController: UITableViewController {
    private var loaded = false
    private var programs = [NPOProgram]() {
        didSet {
            tableView.reloadData()
            setupInitialUI()
        }
    }
    
    // swiftlint:disable force_unwrapping
    private var uniqueLetters: [String] {
        get {
            let firstLetters = self.programs.filter({ $0.firstLetter != nil }).map({ $0.firstLetter! })
            return Array(Set(firstLetters)).sort()
        }
    }
    // swiftlint:enable force_unwrapping
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaded = false
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchPrograms()
        
        // select the first element
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        // update the current detailed view
        updateDetailedView(forRow: indexPath.row)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupInitialUI()
    }
    
    //MARK: Networking
    
    private func fetchPrograms() {
        NPOManager.sharedInstance.getPrograms() { [weak self] programs, error in
            guard let programs = programs else {
                DDLogError("Could not fetch programs (\(error))")
                return
            }
            
            self?.programs = programs
        }
    }
    
    //MARK: Initial load
    
    //swiftlint:disable force_cast
    private func setupInitialUI() {
        guard !loaded && programs.count > 0 else {
            return
        }
        
        // mark as loaded
        loaded = true
        
        // get a random program and use it to set the background
        let randomProgram = programs.randomElement()
        let vc = self.splitViewController as! ProgramSplitViewController
        vc.configure(withProgram: randomProgram)
        
        // select the first element
        guard tableView.indexPathForSelectedRow == nil else {
            return
        }
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Middle)
        
        // load the detailed view for the first element
        updateDetailedView(forRow: indexPath.row)
    }
    //swiftlint:enable force_cast
    
    //MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.uniqueLetters.count ?? 0) + 1
    }
    
    // swiftlint:disable force_cast
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCells.ProgramGroup.rawValue, forIndexPath: indexPath) as! ProgramRootTableViewCell
        let row = indexPath.row
        
        if row == 0 {
            let programCount = self.programs.filter({ $0.favorite }).count ?? 0
            cell.configure(withName: "♥︎", andCount: programCount)
        } else {
            let letter = self.uniqueLetters[row - 1]
            let programCount = self.programs.filter({ $0.firstLetter == letter }).count ?? 0
            cell.configure(withName: letter, andCount: programCount)
        }
        
        return cell
    }
    // swiftlint:enable force_cast
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        updateDetailedView(forRow: indexPath.row)
    }
    
    private func updateDetailedView(forRow row: Int) {
        let programs: [NPOProgram]
        
        if row == 0 {
            programs = self.programs.filter({ $0.favorite })
        } else {
            let letter = self.uniqueLetters[row - 1]
            programs = self.programs.filter({ $0.firstLetter == letter })
        }
        
        guard let vcs = self.splitViewController?.viewControllers where vcs.count > 1, let vc = vcs[1] as? ProgramDetailedCollectionViewController else {
            return
        }
        
        vc.configure(withPrograms: programs)
    }
}
