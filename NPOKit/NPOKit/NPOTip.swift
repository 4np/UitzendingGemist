//
//  NPOTip.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

public class NPOTip: NPOImage {
    // http://apps-api.uitzendinggemist.nl/tips.json
    public private(set) var name: String?
    public private(set) var description: String?
    public private(set) var episode: NPOEpisode?
    public private(set) var published: NSDate?
    public private(set) var position: Int?
    
    public var publishedDisplayValue: String {
        get {
            guard let published = self.published else {
                return NSLocalizedString("onbekend", comment: "Unkown")
            }
            
            let today = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
            let compareDate = NSCalendar.currentCalendar().startOfDayForDate(published)
            
            let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Day], fromDate: compareDate, toDate: today, options: NSCalendarOptions.init(rawValue: 0))
            let days = diffDateComponents.day
            
            switch days {
                case 0:
                    return NSLocalizedString("vandaag", comment: "Today")
                case 1:
                    return NSLocalizedString("gisteren", comment: "Yesterday")
                case 2:
                    return NSLocalizedString("eergisteren", comment: "Day before yesterday")
                default:
                    let text = NSLocalizedString("%d dagen geleden", comment: "Number of days ago")
                    return String.localizedStringWithFormat(text, days)
            }
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        name <- map["name"]
        description <- map["description"]
        episode <- map["episode"]
        published <- (map["published_at"], DateTransform())
        position <- map["position"]
    }
    
    //MARK: Video Stream
    
    public func getVideoStream(withCompletion completed: (url: NSURL?, error: NPOError?) -> () = { url, error in }) {
        guard let episode = self.episode else {
            completed(url: nil, error: .NoEpisodeError)
            return
        }
        
        episode.getVideoStream(withCompletion: completed)
    }
}
