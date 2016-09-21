//
//  NPOStream.swift
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

public enum NPOStreamURLType: String {
    case Standard = "h264_std"   // standard?
    case Medium = "h264_bb"      // broad band?
    case Small = "h264_sb"       // small band?
    case Unknown
    
    // best stream type
    static let best = Standard
    
    // all stream types (except for unknown)
    static let all = [Standard, Medium, Small]
}

open class NPOStream: Mappable, CustomDebugStringConvertible {
    fileprivate var success = false
    fileprivate var urls = [String]()
    fileprivate var family: String?
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        success <- map["succes"]
        urls <- map["streams"]
        family <- map["family"]
    }
    
    // MARK: Accessors
    
    open func getStreamURL(forType type: NPOStreamURLType) -> URL? {
        guard let jsonpURL = self.urls.filter({ $0.range(of: type.rawValue) != nil }).first, let jsonpComponents = URLComponents(string: jsonpURL) else {
            return nil
        }
        
        // get rid of the jsonp part
        var components = URLComponents()
        components.scheme = jsonpComponents.scheme
        components.host = jsonpComponents.host
        components.path = jsonpComponents.path
        
        return components.url
    }
}
