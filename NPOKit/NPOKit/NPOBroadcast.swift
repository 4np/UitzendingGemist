//
//  NPOBroadcast.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 22/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper
import CocoaLumberjack

public class NPOBroadcast: Mappable, CustomDebugStringConvertible {
    public internal(set) var rerun: Bool = false
    public internal(set) var starts: NSDate?
    public internal(set) var ends: NSDate?
    public internal(set) var duration: Int = 0
    public internal(set) var channel: String?
    public internal(set) var episode: NPOEpisode?
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        rerun <- map["rerun"]
        starts <- (map["starts_at"], DateTransform())
        ends <- (map["ends_at"], DateTransform())
        duration <- map["duration"]
        channel <- map["channel_or_net"]
        episode <- map["episode"]
    }
}
