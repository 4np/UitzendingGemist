//
//  NPOBroadcast.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 22/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

open class NPOBroadcast: Mappable, CustomDebugStringConvertible {
    open internal(set) var rerun: Bool = false
    open internal(set) var starts: Date?
    open internal(set) var ends: Date?
    open internal(set) var duration: Int = 0
    open internal(set) var channel: String?
    open internal(set) var episode: NPOEpisode?
    
    // MARK: Lifecycle
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        rerun <- map["rerun"]
        starts <- (map["starts_at"], DateTransform())
        ends <- (map["ends_at"], DateTransform())
        duration <- map["duration"]
        channel <- map["channel_or_net"]
        episode <- map["episode"]
    }
}
