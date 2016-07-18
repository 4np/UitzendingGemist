//
//  Int+Time.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 18/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension Int {
    public var time: (weeks: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        get {
            return (
                weeks: self / (3600 * 24 * 7),
                days: self / (3600 * 24),
                hours: self / 3600,
                minutes: (self % 3600) / 60,
                seconds: (self % 3600) % 60
            )
        }
    }
    
    public var timeDisplayValue: String {
        let time = self.time
        var components = [String]()
        
        if let weeks = self.getTimeDisplayValue(forValue: time.weeks, withFormat: NPOConstants.durationInWeeksText) {
            components.append(weeks)
        }
        
        if let days = self.getTimeDisplayValue(forValue: time.days, withFormat: NPOConstants.durationInDaysText) {
            components.append(days)
        }
        
        if let hours = self.getTimeDisplayValue(forValue: time.hours, withFormat: NPOConstants.durationInHoursText) {
            components.append(hours)
        }
        
        if let minutes = self.getTimeDisplayValue(forValue: time.minutes, withFormat: NPOConstants.durationInMinutesText) {
            components.append(minutes)
        }
        
        if let seconds = self.getTimeDisplayValue(forValue: time.seconds, withFormat: NPOConstants.durationInSecondsText) {
            components.append(seconds)
        }
        
        return components.joinWithSeparator(", ")
    }
    
    private func getTimeDisplayValue(forValue value: Int, withFormat format: String) -> String? {
        guard value > 0 else {
            return nil
        }
        
        return String.localizedStringWithFormat(format, value)
    }
}
