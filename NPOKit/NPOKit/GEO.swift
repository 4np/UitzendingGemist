//
//  GEO.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 13/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

//https://freegeoip.net/json/

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

open class GEO: Mappable, CustomDebugStringConvertible {
    open internal(set) var countryCode: String?
    open internal(set) var countryName: String?
    open internal(set) var regionCode: String?
    open internal(set) var regionName: String?
    open internal(set) var city: String?
    open internal(set) var zipCode: String?
    open internal(set) var timeZone: String?
    open internal(set) var latitude: Float?
    open internal(set) var longitude: Float?
    open internal(set) var metroCode: String?
    
    // MARK: Lifecycle
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        countryCode <- map["country_code"]
        countryName <- map["country_name"]
        regionCode <- map["region_code"]
        regionName <- map["regio_name"]
        city <- map["city"]
        zipCode <- map["zip_code"]
        timeZone <- map["time_zone"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        metroCode <- map["metro_code"]
    }
}
