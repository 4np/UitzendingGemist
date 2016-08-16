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
                displayName += UitzendingGemistConstants.unwatchedSymbol //partiallyWatchedSymbol
                break
            case .Unwatched:
                displayName += UitzendingGemistConstants.unwatchedSymbol
                break
        }
        
        // add the program name
        displayName += name ?? UitzendingGemistConstants.unknownProgramName
        
        return displayName
    }
    
    func getDisplayNameWithFavoriteIndicator() -> String {
        var displayName = name ?? ""
        
        // add favorite icon
        if favorite {
            displayName += UitzendingGemistConstants.favoriteSymbol
        }
        
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
        return favorite ? UIColor.waxFlower : UIColor.orangeColor()
    }
    
    func getUnfocusedColor() -> UIColor {
        return favorite ? UIColor.waxFlower : UIColor.whiteColor()
    }
    
    func getFocusedColor() -> UIColor {
        return favorite ? UIColor.waxFlower : UIColor.blackColor()
    }
}
