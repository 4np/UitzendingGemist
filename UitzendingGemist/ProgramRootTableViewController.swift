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
    fileprivate var loaded = false
    fileprivate var programs = [NPOProgram]() {
        didSet {
            tableView.reloadData()
            setupInitialUI()
        }
    }
    
    // swiftlint:disable force_unwrapping
    fileprivate var uniqueLetters: [String] {
        get {
            let firstLetters = self.programs.filter({ $0.firstLetter != nil }).map({ $0.firstLetter! })
            return Array(Set(firstLetters)).sorted()
        }
    }
    // swiftlint:enable force_unwrapping
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loaded = false
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchPrograms()
        
        // select the first element
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        // update the current detailed view
        updateDetailedView(forRow: (indexPath as NSIndexPath).row)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupInitialUI()
    }
    
    //MARK: Networking
    
    fileprivate func fetchPrograms() {
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
    fileprivate func setupInitialUI() {
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
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
        
        // load the detailed view for the first element
        updateDetailedView(forRow: (indexPath as NSIndexPath).row)
    }
    //swiftlint:enable force_cast
    
    //MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.uniqueLetters.count ?? 0) + 1
    }
    
    // swiftlint:disable force_cast
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.ProgramGroup.rawValue, for: indexPath) as! ProgramRootTableViewCell
        let row = (indexPath as NSIndexPath).row
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateDetailedView(forRow: (indexPath as NSIndexPath).row)
    }
    
    fileprivate func updateDetailedView(forRow row: Int) {
        let programs: [NPOProgram]
        
        if row == 0 {
            programs = self.programs.filter({ $0.favorite })
        } else {
            let letter = self.uniqueLetters[row - 1]
            programs = self.programs.filter({ $0.firstLetter == letter })
        }
        
        guard let vcs = self.splitViewController?.viewControllers , vcs.count > 1, let vc = vcs[1] as? ProgramDetailedCollectionViewController else {
            return
        }
        
        vc.configure(withPrograms: programs)
    }
}
