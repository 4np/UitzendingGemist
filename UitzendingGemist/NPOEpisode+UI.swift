//
//  NPOEpisode+UI.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 31/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit

extension NPOEpisode {
    public var watchedIndicator: String {
        get {
            // add (partically) watched indicator
            switch watched {
                case .Unwatched:
                    return UitzendingGemistConstants.unwatchedSymbol
                case .Partially:
                    return UitzendingGemistConstants.partiallyWatchedSymbol
                case .Fully:
                    return UitzendingGemistConstants.watchedSymbol
            }
        }
    }
    
    func getDisplayName() -> String {
        var displayName = watchedIndicator
        
        // add the episode name
        if let name = self.name where !name.isEmpty {
            displayName += name
        } else if let name = self.program?.name where !name.isEmpty {
            displayName += name
        } else {
            displayName += UitzendingGemistConstants.unknownEpisodeName
        }
        
        return displayName
    }
    
    func getTime() -> String? {
        guard let broadcasted = self.broadcasted else {
            return nil
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.stringFromDate(broadcasted)
    }
    
    func getNames() -> (programName: String, episodeNameAndInfo: String) {
        // define the program name
        var programName = watchedIndicator
        
        if let name = self.program?.name where !name.isEmpty {
            programName += name
        } else {
            programName += UitzendingGemistConstants.unknownProgramName
        }
        
        // define the episode name and time
        var elements = [String]()
        
        // add episode name
        if let name = self.name where !name.isEmpty {
            if let tempProgramName = program?.name {
                var tempName = name
                
                // replace program name
                tempName = tempName.stringByReplacingOccurrencesOfString(tempProgramName, withString: "", options: .CaseInsensitiveSearch, range: nil)
                
                // remove garbage from beginning of name
                if let regex = try? NSRegularExpression(pattern: "^([^a-z0-9]+)", options: .CaseInsensitive) {
                    let range = NSRange(0..<tempName.utf16.count)
                    tempName = regex.stringByReplacingMatchesInString(tempName, options: .WithTransparentBounds, range: range, withTemplate: "")
                }

                // capitalize
                tempName = tempName.capitalizedString
                
                if !tempName.isEmpty {
                    elements.append(tempName)
                }
            } else {
                elements.append(name)
            }
        }
        
        // add time
        if let time = getTime() {
            elements.append(time)
        }
        
        // add duration
        elements.append(self.duration.timeDisplayValue)
        
        let episodeName = elements.joinWithSeparator(UitzendingGemistConstants.separator)
        
        return (programName: programName, episodeNameAndInfo: episodeName)
    }
}
