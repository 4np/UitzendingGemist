//
//  NPORestriction.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

import CocoaLumberjack

public class NPORestriction: Mappable, CustomDebugStringConvertible {
    public internal(set) var age = false
    public internal(set) var location = false
    internal var time: NPOTimeRestriction?
    
    public var available: Bool {
        get {
            let available = self.time?.available ?? true
            return available && self.geoAllowed()
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        age <- map["age_restriction"]
        location <- map["geoIP_restriction"]
        time <- map["time_restriction"]
    }
    
    //MARK: Geo check
    
    internal func geoAllowed() -> Bool {
        guard location else {
            return true
        }
        
        //TODO: Geo check
//        let locale = NSLocale.currentLocale()
//        if let country = locale.objectForKey(NSLocaleCountryCode) as? String {
//            DDLogDebug("locale: \(country)")
//            if country == "US" {
//                return true
//            }
//        }
        
        return true
    }
}
