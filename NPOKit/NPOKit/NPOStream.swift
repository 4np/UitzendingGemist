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

public class NPOStream: Mappable, CustomDebugStringConvertible {
    private var success = false
    private var urls = [String]()
    private var family: String?
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        success <- map["succes"]
        urls <- map["streams"]
        family <- map["family"]
    }
    
    //MARK: Accessors
    
    public func getStreamURL(forType type: NPOStreamURLType) -> NSURL? {
        guard let jsonpURL = self.urls.filter({ $0.rangeOfString(type.rawValue) != nil }).first, jsonpComponents = NSURLComponents(string: jsonpURL) else {
            return nil
        }
        
        // get rid of the jsonp part
        let components = NSURLComponents()
        components.scheme = jsonpComponents.scheme
        components.host = jsonpComponents.host
        components.path = jsonpComponents.path
        
        return components.URL
    }
}
