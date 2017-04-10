//
//  NPOTip+UI.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 31/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit

extension NPOTip {
    func getDisplayName() -> String {
        var displayName = episode?.watchedIndicator ?? ""
        
        if let name = self.name, !name.isEmpty {
            displayName += name
        } else if let name = episode?.name, !name.isEmpty {
            displayName += name
        } else {
            displayName += String.unknownText
        }
        
        return displayName
    }
}
