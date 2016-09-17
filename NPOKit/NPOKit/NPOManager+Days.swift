//
//  NPOManager+Days.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 01/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit

extension NPOManager {
    public func getDaysSinceNow(numberOfDays total: Int) -> [(from: Date, to: Date, label: String, name: String)] {
        guard total >= 0 else {
            return []
        }
        
        var days = [(from: Date, to: Date, label: String, name: String)]()
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"
        
        for daysAgo in 0..<total {
            guard let day = now.date(byAddingNumberOfDays: -daysAgo) else {
                continue
            }
            
            let startAndEnd = day.startAndEndOfDate()
            let dayInfo = (from: startAndEnd.from, to: startAndEnd.to, label: day.daysAgoDisplayValue, name: formatter.string(from: day))
            days.append(dayInfo)
        }
        
        return days
    }
}
