//
//  NPODetailedMedia.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

public class NPODetailedMedia: NPORestrictedMedia {
    public internal(set) var broadcasters = [NPOBroadcaster]()
    public internal(set) var genres = [NPOGenre]()
    public internal(set) var duration: Int = 0
    public internal(set) var advisories = [String]()
    public internal(set) var broadcasted: NSDate?
    public internal(set) var broadcastChannel: String?
    public internal(set) var program: NPOProgram?
    
    public var broadcastedDisplayValue: String {
        guard let broadcasted = self.broadcasted else {
            return NPOConstants.unknownText
        }
        
        return broadcasted.daysAgoDisplayValue
    }
    
    public var durationDisplayValue: String {
        //let days: Int = duration / (3600 * 24)
        let hours: Int = duration / 3600
        let minutes: Int = (duration % 3600) / 60
        let seconds: Int = (duration % 3600) % 60
        
        if hours > 0 {
            return String.localizedStringWithFormat(NPOConstants.durationInHoursAndMinutesText, hours, minutes)
        } else if minutes > 0 {
            return String.localizedStringWithFormat(NPOConstants.durationInMinutesText, minutes)
        } else {
            return String.localizedStringWithFormat(NPOConstants.durationInSecondsText, seconds)
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        broadcasters <- (map["broadcasters"], EnumTransform<NPOBroadcaster>())
        genres <- (map["genres"], EnumTransform<NPOGenre>())
        duration <- map["duration"]
        advisories <- map["advisories"]
        broadcasted <- (map["broadcasted_at"], DateTransform())
        broadcastChannel <- map["broadcasted_on"]
        program <- map["series"]
    }
}
