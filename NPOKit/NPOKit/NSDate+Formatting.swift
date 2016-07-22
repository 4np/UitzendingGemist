//
//  NSDate+Formatting.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 16/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import CocoaLumberjack

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
    
    public var npoDate: NSDate {
        // For the NPO the day ends at 06:00 am at which time the new 
        // programming schedule starts. This means that for API calls
        // that require a date (e.g. yyyy-mm-dd) before 06:00 am in the
        // morning you need to use _yesterday's_ date instead.

        // start of this date (e.g. 00:00)
        let startOfDate = NSCalendar.currentCalendar().startOfDayForDate(self)
        
        // add six hours to get to 06:00 am in the morning
        let components = NSDateComponents()
        components.hour = 6
        let sixAM = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDate, options: NSCalendarOptions())
        
        // check if the current date is earlier than 06:00 am in the morning...
        guard let earlyInTheMorning = sixAM where self.compare(earlyInTheMorning) == .OrderedAscending else {
            // no, leave the date as is
            return self
        }
        
        // yes, the date is earlier so subtract a day to return yesterday's date instead
        components.hour = 0
        components.day = -1
        guard let yesterday = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: NSCalendarOptions()) else {
            // something went wrong
            DDLogError("Found nil when subtracting a day of date '\(self.description)'")
            return self
        }
        
        // and done, return yesterday's date instead
        return yesterday
    }
    
    public var formattedNPODate: String {
        // format the NPO date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(self.npoDate)
    }
    
    public func liesBetween(startDate start: NSDate?, endDate end: NSDate?) -> Bool {
        return self.lies(after: start, inclusive: true) && self.lies(before: end)
    }
    
    public func lies(before date: NSDate?) -> Bool {
        guard let comparison = date?.compare(self) else {
            return false
        }
        
        return comparison == .OrderedDescending
    }
    
    public func lies(after date: NSDate?, inclusive: Bool) -> Bool {
        guard let comparison = date?.compare(self) else {
            return false
        }
        
        return ((inclusive && comparison == .OrderedSame) || comparison == .OrderedAscending)
    }
}
