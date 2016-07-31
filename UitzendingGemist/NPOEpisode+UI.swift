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
            if !watched && watchDuration > 59 {
                return UitzendingGemistConstants.partiallyWatchedSymbol
            } else if !watched {
                return UitzendingGemistConstants.unwatchedSymbol
            } else {
                return UitzendingGemistConstants.watchedSymbol
            }
        }
    }
    
    func getDisplayName() -> String {
        var displayName = watchedIndicator
        
        // add the episode name
        if let name = self.name where !name.isEmpty {
            displayName += name
        } else {
            displayName += UitzendingGemistConstants.unknownEpisodeName
        }
        
        return displayName
    }
}
