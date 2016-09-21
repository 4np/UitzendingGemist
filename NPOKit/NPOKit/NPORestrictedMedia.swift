//
//  NPORestrictedMedia.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

open class NPORestrictedMedia: NPOMedia {
    open internal(set) var description: String?
    open internal(set) var broadcasters = [NPOBroadcaster]()
    open internal(set) var genres = [NPOGenre]()
    internal var revoked = false
    internal var active = true
    open internal(set) var restriction: NPORestriction?
    open internal(set) var views = 0
    open internal(set) var stills: [NPOStill]?
    open internal(set) var fragments: [NPOFragment]?
    
    open var available: Bool {
        get {
            let restrictionOkay = restriction?.available ?? true
            return !self.revoked && self.active && restrictionOkay
        }
    }
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: Mapping
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        description <- map["description"]
        broadcasters <- (map["broadcasters"], EnumTransform<NPOBroadcaster>())
        genres <- (map["genres"], EnumTransform<NPOGenre>())
        revoked <- map["revoked"]
        active <- map["active"]
        restriction <- map["restrictions"]
        stills <- map["stills"]
        fragments <- map["fragments"]
        views <- map["views"]
    }
}
