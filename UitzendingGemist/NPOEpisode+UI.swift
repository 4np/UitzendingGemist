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
        // add (partically) watched indicator
        switch watched {
            case .unwatched:
                return UitzendingGemistConstants.unwatchedSymbol
            case .partially:
                return UitzendingGemistConstants.partiallyWatchedSymbol
            case .fully:
                return UitzendingGemistConstants.watchedSymbol
        }
    }
    
    func getDisplayName() -> String {
        var displayName = watchedIndicator
        
        // add the episode name
        if let name = self.name, !name.isEmpty {
            displayName += name
        } else if let name = self.program?.name, !name.isEmpty {
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: broadcasted)
    }
    
    func getNames() -> (programName: String, episodeNameAndInfo: String) {
        // define the program name
        var programName = watchedIndicator
        
        if let name = self.program?.name, !name.isEmpty {
            programName += name
        } else {
            programName += UitzendingGemistConstants.unknownProgramName
        }
        
        // define the episode name and time
        var elements = [String]()
        
        // add episode name
        if let name = self.name, !name.isEmpty {
            if let tempProgramName = program?.name {
                var tempName = name
                
                // replace program name
                tempName = tempName.replacingOccurrences(of: tempProgramName, with: "", options: .caseInsensitive, range: nil)
                
                // remove garbage from beginning of name
                if let regex = try? NSRegularExpression(pattern: "^([^a-z0-9]+)", options: .caseInsensitive) {
                    let range = NSRange(0..<tempName.utf16.count)
                    tempName = regex.stringByReplacingMatches(in: tempName, options: .withTransparentBounds, range: range, withTemplate: "")
                }

                // capitalize
                tempName = tempName.capitalized
                
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
        
        let episodeName = elements.joined(separator: UitzendingGemistConstants.separator)
        
        return (programName: programName, episodeNameAndInfo: episodeName)
    }
}
