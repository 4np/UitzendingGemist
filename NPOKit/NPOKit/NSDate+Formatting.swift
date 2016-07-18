//
//  NSDate+Formatting.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 16/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension NSDate {
    public var daysAgoDisplayValue: String {
        get {
            let today = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
            let compareDate = NSCalendar.currentCalendar().startOfDayForDate(self)
            
            let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Day], fromDate: compareDate, toDate: today, options: NSCalendarOptions.init(rawValue: 0))
            let days = diffDateComponents.day
            
            switch days {
                case 0:
                    return NPOConstants.todayText
                case 1:
                    return NPOConstants.yesterdayText
                case 2:
                    return NPOConstants.dayBeforeYesterdayText
                default:
                    return String.localizedStringWithFormat(NPOConstants.daysAgoText, days)
            }
        }
    }
}
