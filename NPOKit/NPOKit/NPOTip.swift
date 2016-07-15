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

public class NPOTip: NPOImage { //, NPOResource {
    // http://apps-api.uitzendinggemist.nl/tips.json
    public private(set) var name: String?
    public private(set) var description: String?
    public private(set) var episode: NPOEpisode?
    public private(set) var published: NSDate?
    public private(set) var position: Int?
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
//    //MARK: NPOResource
//    
//    static func path() -> String {
//        return "tips.json"
//    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        name <- map["name"]
        description <- map["description"]
        episode <- map["episode"]
        published <- (map["published_at"], DateTransform())
        position <- map["position"]
    }
}
