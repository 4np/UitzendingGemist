//
//  NPOStill.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

open class NPOStill: NPOImage {
    open fileprivate(set) var position: Int?
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: Mapping
    
    open override func mapping(map: Map) {
        imageURL <- (map["url"], URLTransform())
        position <- map["offset"]
    }
}
