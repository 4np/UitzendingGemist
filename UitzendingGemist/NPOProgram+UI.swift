//
//  NPOProgram+UI.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 31/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit

extension NPOProgram {
    func getDisplayNameWithWatchedIndicator() -> String {
        var displayName = ""
        
        switch watched {
        case .Fully:
            displayName += UitzendingGemistConstants.watchedSymbol
            break
        case .Partially:
            displayName += UitzendingGemistConstants.partiallyWatchedSymbol
            break
        case .Unwatched:
            displayName += UitzendingGemistConstants.unwatchedSymbol
            break
        }
        
        // add the program name
        displayName += name ?? UitzendingGemistConstants.unknownProgramName
        
        return displayName
    }

    func getDisplayName() -> String {
        var displayName = getDisplayNameWithWatchedIndicator()
        
        // add favorite icon
        if favorite {
            displayName += UitzendingGemistConstants.favoriteSymbol
        }
        
        return displayName
    }
    
    func getDisplayColor() -> UIColor {
        return favorite ? UIColor.waxFlower : UIColor.whiteColor()
    }
    
    func getFocusColor() -> UIColor {
        return favorite ? UIColor.waxFlower : UIColor.blackColor()
    }
}
