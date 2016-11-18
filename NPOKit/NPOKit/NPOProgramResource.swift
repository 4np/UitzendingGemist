//
//  NPOProgramResource.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 18/11/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

// Curated list of additional program resources
open class NPOProgramResource: Mappable, CustomDebugStringConvertible {
    open internal(set) var mid: String?
    open internal(set) var name: String?
    open internal(set) var youTubeChannel: String?
    
    // MARK: Lifecycle
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        mid <- map["mid"]
        name <- map["name"]
        youTubeChannel <- map["youtube_channel"]
    }
}
