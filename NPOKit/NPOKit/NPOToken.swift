//
//  NPOToken.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 21/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import ObjectMapper

open class NPOToken: Mappable, CustomDebugStringConvertible {
    private static let lifetime = 3600 // token lifetime in seconds (1h)
    internal private(set) var token: String?
    internal private(set) var date = Date()

    internal var age: Double {
        return Date().timeIntervalSince(date)
    }
    
    private var expiryDate: Date? {
        return Date(timeInterval: Double(NPOToken.lifetime), since: date)
    }
    
    internal var hasExpired: Bool {
        guard let expiryDate = self.expiryDate else {
            return true
        }
        
        let now = Date()
        let comparison = expiryDate.compare(now)
        return (comparison == .orderedAscending || comparison == .orderedSame)
    }
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        token <- map["token"]
    }
}
