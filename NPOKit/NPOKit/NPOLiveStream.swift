//
//  NPOLiveStream.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 21/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper

public class NPOLiveStream: Mappable, CustomDebugStringConvertible {
    public private(set) var success = false
    public private(set) var url: NSURL?
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        success <- map["success"]
        url <- (map["stream"], URLTransform())
    }
}
