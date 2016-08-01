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
        } else {
            displayName += UitzendingGemistConstants.unknownEpisodeName
        }
        
        return displayName
    }
}
