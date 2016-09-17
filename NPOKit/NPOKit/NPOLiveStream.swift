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

open class NPOLiveStream: Mappable, CustomDebugStringConvertible {
    open fileprivate(set) var success = false
    open fileprivate(set) var url: URL?
    
    //MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    //MARK: Mapping
    
    open func mapping(map: Map) {
        success <- map["success"]
        url <- (map["stream"], URLTransform())
    }
}
