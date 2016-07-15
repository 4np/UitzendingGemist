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

public class NPOTimeRestriction: Mappable, CustomDebugStringConvertible {
    internal(set) var online: NSDate?
    internal(set) var offline: NSDate?
    
    public var available: Bool {
        get {
            return self.isOnline()
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        online <- (map["online_at"], DateTransform())
        offline <- (map["offline_at"], DateTransform())
    }
    
    //MARK: Date checking
    
    internal func isOnline() -> Bool {
        return self.isOnline(atDate: NSDate())
    }
    
    internal func isOnline(atDate date: NSDate) -> Bool {
        guard let online = self.online, offline = self.offline else {
            return true
        }
        
        return (date.compare(online) == .OrderedDescending && date.compare(offline) == .OrderedAscending)
    }
}
