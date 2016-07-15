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

public class NPOFragment: NPOMedia {
    public internal(set) var description: String?
    public internal(set) var startsAt = 0
    public internal(set) var endsAt = 0
    public internal(set) var duration = 0
    public internal(set) var stills = [NPOStill]()
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        description <- map["description"]
        startsAt <- map["starts_at"]
        endsAt <- map["ends_at"]
        duration <- map["duration"]
        stills <- map["stills"]
    }
}
