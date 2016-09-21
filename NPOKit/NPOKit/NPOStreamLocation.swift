//
//  NPOStreamLocation.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper

open class NPOStreamLocation: Mappable, CustomDebugStringConvertible {
    fileprivate var errorcode: Int?
    fileprivate var family: String?
    fileprivate var path: String?
    fileprivate var scheme: String?
    fileprivate var host: String?
    fileprivate var wait: Int?
    fileprivate var query: String?
    open internal(set) var url: URL?
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        errorcode <- map["errorcode"]
        family <- map["family"]
        path <- map["path"]
        scheme <- map["protocol"]
        host <- map["server"]
        wait <- map["wait"]
        query <- map["querystring.odiredirecturl.value"]
        url <- (map["url"], URLTransform())
    }
}
