//
//  NPOFragment.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

open class NPOFragment: NPOMedia {
    open internal(set) var description: String?
    open internal(set) var startsAt = 0
    open internal(set) var endsAt = 0
    open internal(set) var duration = 0
    open internal(set) var stills = [NPOStill]()
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: Mapping
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        description <- map["description"]
        startsAt <- map["starts_at"]
        endsAt <- map["ends_at"]
        duration <- map["duration"]
        stills <- map["stills"]
    }
}
