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

public class NPOStreamLocation: Mappable, CustomDebugStringConvertible {
    private var errorcode: Int?
    private var family: String?
    private var path: String?
    private var scheme: String?
    private var host: String?
    private var wait: Int?
    private var query: String?
    public internal(set) var url: NSURL?
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
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
