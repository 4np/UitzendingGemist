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
    
    fileprivate var githubUsername = "4np"
    fileprivate var githubRepository = "UitzendingGemist"
    fileprivate var checkAfterDays = 1
    fileprivate var lastCheckDate: Date?
    
    fileprivate func shouldCheckForUpdates() -> Bool {
        guard let lastCheckDate = self.lastCheckDate else {
            return true
        }
        
        let now = Date()
        let diffDateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.day], from: lastCheckDate, to: now, options: NSCalendar.Options.init(rawValue: 0))
        let days = diffDateComponents.day ?? 0
        
        // check if we should compare versions with the latest GitHub tag
        return days >= self.checkAfterDays
    }
    
    func updateAvailable(withCompletion completed: @escaping (_ release: GitHubRelease?, _ currentVersion: String?) -> Void = { release in }) {
        guard self.shouldCheckForUpdates() else {
            return
        }
        
        // get the current version
        guard let myVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        // get the latest tag
        NPOManager.sharedInstance.getGitHubReleases(forUsername: self.githubUsername, andRepositoryName: self.githubRepository) { [weak self] releases, error in
            self?.lastCheckDate = Date()
            
            guard let releases = releases, let latestRelease = releases.filter({ $0.active }).first, let latestVersion = latestRelease.version else {
                DDLogError("Could not get latest version information from GitHub (\(String(describing: error)))")
                return
            }
            
            if myVersion.compare(latestVersion, options: .numeric) == .orderedAscending {
                DDLogDebug("Newer version available (current: \(myVersion), latest: \(latestVersion))")
                completed(latestRelease, myVersion)
            } else {
                DDLogDebug("No update available (current: \(myVersion), latest: \(latestVersion))")
            }
        }
    }
}
