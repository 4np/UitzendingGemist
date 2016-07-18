//
//  NPOConstants.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 16/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

internal class NPOConstants {
    static let unknownText = NSLocalizedString("onbekend", comment: "Unkown")
    static let todayText = NSLocalizedString("vandaag", comment: "Today")
    static let yesterdayText = NSLocalizedString("gisteren", comment: "Yesterday")
    static let dayBeforeYesterdayText = NSLocalizedString("eergisteren", comment: "Day before yesterday")
    static let daysAgoText = NSLocalizedString("%d dagen geleden", comment: "Number of days ago")
    
    static let durationInHoursAndMinutesText = NSLocalizedString("%d u %d min", comment: "Duration in hours and minutes")
    static let durationInMinutesText = NSLocalizedString("%d min", comment: "Duration in minutes")
    static let durationInSecondsText = NSLocalizedString("%d sec", comment: "Duration in seconds")
}
