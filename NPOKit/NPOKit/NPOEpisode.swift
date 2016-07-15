//
//  NPOEpisode.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

public class NPOEpisode: NPODetailedMedia {
    // Episode specific properties
    // http://apps-api.uitzendinggemist.nl/episodes/AT_2049573.json
    // http://apps-api.uitzendinggemist.nl/tips.json
    // http://apps-api.uitzendinggemist.nl/episodes/popular.json
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
       
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
    }
}
