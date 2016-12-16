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

open class NPORestriction: Mappable, CustomDebugStringConvertible {
    open internal(set) var age = false
    open internal(set) var location = false
    internal var time: NPOTimeRestriction?
    
    open var available: Bool {
        let available = self.time?.available ?? true
        return available && self.geoAllowed()
    }
    
    // MARK: Lifecycle
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        age <- map["age_restriction"]
        location <- map["geoIP_restriction"]
        time <- map["time_restriction"]
    }
    
    // MARK: Geo check
    
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
