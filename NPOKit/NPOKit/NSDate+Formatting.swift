//
//  NSDate+Formatting.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 16/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import CocoaLumberjack

extension Date {
    public var daysAgoDisplayValue: String {
        get {
            let today = Calendar.current.startOfDay(for: Date())
            let compareDate = Calendar.current.startOfDay(for: self)
            
            let diffDateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.day], from: compareDate, to: today, options: NSCalendar.Options.init(rawValue: 0))
            let days = diffDateComponents.day ?? 0
            
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
    
    public var npoDate: Date {
        // For the NPO the day ends at 06:00 am at which time the new 
        // programming schedule starts. This means that for API calls
        // that require a date (e.g. yyyy-mm-dd) before 06:00 am in the
        // morning you need to use _yesterday's_ date instead.

        // start of this date (e.g. 00:00)
        let startOfDate = Calendar.current.startOfDay(for: self)
        
        // add six hours to get to 06:00 am in the morning
        var components = DateComponents()
        components.hour = 6
        let sixAM = (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDate, options: NSCalendar.Options())
        
        // check if the current date is earlier than 06:00 am in the morning...
        guard let earlyInTheMorning = sixAM, self.compare(earlyInTheMorning) == .orderedAscending else {
            // no, leave the date as is
            return self
        }
        
        // yes, the date is earlier so subtract a day to return yesterday's date instead
        components.hour = 0
        components.day = -1
        guard let yesterday = (Calendar.current as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options()) else {
            // something went wrong
            DDLogError("Found nil when subtracting a day of date '\(self.description)'")
            return self
        }
        
        // and done, return yesterday's date instead
        return yesterday
    }
    
    public var isEarlierThanSixAM: Bool {
        // start of this date (e.g. 00:00)
        let startOfDate = Calendar.current.startOfDay(for: self)
        
        // add six hours to get to 06:00 am in the morning
        var components = DateComponents()
        components.hour = 6
        let sixAM = (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDate, options: NSCalendar.Options())
        
        // check if the current date is earlier than 06:00 am in the morning...
        guard let earlyInTheMorning = sixAM, self.compare(earlyInTheMorning) == .orderedAscending else {
            // no, leave the date as is
            return false
        }
        
        return true
    }
    
    public func date(byAddingNumberOfDays days: Int) -> Date? {
        var components = DateComponents()
        components.day = days
        return (Calendar.current as NSCalendar).date(byAdding: components, to: self, options: NSCalendar.Options())
    }
    
    //swiftlint:disable force_unwrapping
    public func startAndEndOfDate() -> (from: Date, to: Date) {
        var from: Date?
        var to: Date?
        
        if self.isEarlierThanSixAM {
            from = self.date(byAddingNumberOfDays: -1)?.sixAM
            to = self.fiveFiftyNineAM
        } else {
            from = self.sixAM
            to = self.date(byAddingNumberOfDays: 1)?.fiveFiftyNineAM
        }
        
        return (from: from!, to: to!)
    }
    //swiftlint:enable force_unwrapping
    
    // return 05:59:59 for this date
    public var fiveFiftyNineAM: Date? {
        // start of this date (e.g. 00:00)
        let startOfDate = Calendar.current.startOfDay(for: self)
        
        // add six hours to get to 06:00 am in the morning
        var components = DateComponents()
        components.hour = 5
        components.minute = 59
        components.second = 59
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDate, options: NSCalendar.Options())
    }
    
    // return 06:00 for this date
    public var sixAM: Date? {
        // start of this date (e.g. 00:00)
        let startOfDate = Calendar.current.startOfDay(for: self)
        
        // add six hours to get to 06:00 am in the morning
        var components = DateComponents()
        components.hour = 6
        return (Calendar.current as NSCalendar).date(byAdding: components, to: startOfDate, options: NSCalendar.Options())
    }
    
    public var formattedNPODate: String {
        // format the NPO date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self.npoDate)
    }
    
    public func liesBetween(startDate start: Date?, endDate end: Date?) -> Bool {
        return self.lies(after: start, inclusive: true) && self.lies(before: end)
    }
    
    public func lies(before date: Date?) -> Bool {
        guard let comparison = date?.compare(self) else {
            return false
        }
        
        return comparison == .orderedDescending
    }
    
    public func lies(after date: Date?, inclusive: Bool) -> Bool {
        guard let comparison = date?.compare(self) else {
            return false
        }
        
        return ((inclusive && comparison == .orderedSame) || comparison == .orderedAscending)
    }
}
