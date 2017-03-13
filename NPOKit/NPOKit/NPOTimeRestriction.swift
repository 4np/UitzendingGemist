//
//  NPOTimeRestriction.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

open class NPOTimeRestriction: Mappable, CustomDebugStringConvertible {
    open internal(set) var online: Date?
    open internal(set) var offline: Date?
    
    open var available: Bool {
        return self.isOnline()
    }
    
    // MARK: Lifecycle
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        online <- (map["online_at"], DateTransform())
        offline <- (map["offline_at"], DateTransform())
    }
    
    // MARK: Date checking
    
    internal func isOnline() -> Bool {
        return self.isOnline(atDate: Date())
    }
    
    internal func isOnline(atDate date: Date) -> Bool {
        guard let online = self.online, let offline = self.offline else {
            return true
        }
        
        return (date.compare(online) == .orderedDescending && date.compare(offline) == .orderedAscending)
    }
}
