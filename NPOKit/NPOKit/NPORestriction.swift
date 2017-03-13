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
    open internal(set) var location: String?
    open internal(set) var time: NPOTimeRestriction?
    
    open var available: Bool {
        return isTimeAllowed() && isGeoAllowed()
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
    
    // MARK: Time check
    
    open func isTimeAllowed() -> Bool {
        return self.time?.available ?? true
    }
    
    // MARK: Geo check
    
    open func isGeoAllowed() -> Bool {
        guard let location = location else {
            return true
        }
        
        // make sure that the location matches the current location
        guard let countryCode = NPOManager.sharedInstance.geo?.countryCode, countryCode == location else {
            return false
        }
        
        return true
    }
}
