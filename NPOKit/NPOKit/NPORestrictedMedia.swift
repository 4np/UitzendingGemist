//
//  NPORestrictedMedia.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

public class NPORestrictedMedia: NPOMedia {
    public internal(set) var description: String?
    internal var revoked = false
    internal var active = true
    public internal(set) var restriction: NPORestriction?
    
    public var available: Bool {
        get {
            let restrictionOkay = restriction?.available ?? true
            return !self.revoked && self.active && restrictionOkay
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        description <- map["description"]
        revoked <- map["revoked"]
        active <- map["active"]
        restriction <- map["restrictions"]
    }
}
