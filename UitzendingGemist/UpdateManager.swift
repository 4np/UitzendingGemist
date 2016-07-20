//
//  UpdateManager.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 20/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class UpdateManager {
    static var sharedInstance = UpdateManager()
    
    private var githubUsername = "4np"
    private var githubRepository = "UitzendingGemist"
    private var checkAfterDays = 1
    
    private var lastCheckDate: NSDate?
    
    func updateAvailable(withCompletion completed: (release: GitHubRelease?, currentVersion: String?) -> () = { release in }) {
        let now = NSDate()
        let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Day], fromDate: self.lastCheckDate ?? now, toDate: now, options: NSCalendarOptions.init(rawValue: 0))
        let days = diffDateComponents.day
        
        // check if we should compare versions with the latest GitHub tag
        guard days >= self.checkAfterDays else {
            return
        }
        
        // get the current version
        guard let myVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        // get the latest tag
        NPOManager.sharedInstance.getGitHubReleases(forUsername: self.githubUsername, andRepositoryName: self.githubRepository) { [weak self] releases, error in
            self?.lastCheckDate = NSDate()
            
            guard let releases = releases, latestRelease = releases.filter({ $0.active }).first, latestVersion = latestRelease.version else {
                DDLogError("Could not get latest version information from GitHub (\(error))")
                return
            }
            
            if myVersion.compare(latestVersion, options: NSStringCompareOptions.NumericSearch) == .OrderedAscending {
                DDLogDebug("Newer version available (current: \(myVersion), latest: \(latestVersion)")
                completed(release: latestRelease, currentVersion: myVersion)
            } else {
                DDLogDebug("No update available (current: \(myVersion), latest: \(latestVersion))")
            }
        }
    }
}
