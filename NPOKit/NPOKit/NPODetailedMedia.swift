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

public class NPODetailedMedia: NPORestrictedMedia {
    public internal(set) var broadcasters = [NPOBroadcaster]()
    public internal(set) var genres = [NPOGenre]()
    public internal(set) var duration: Int = 0
    public internal(set) var advisories = [String]()
    public internal(set) var broadcasted: NSDate?
    public internal(set) var broadcastChannel: String?
    public internal(set) var program: NPOProgram?
    
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
