//
//  NPOProgram.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import ObjectMapper

public class NPOProgram: NPORestrictedMedia { //, NPOResource {
    // program specific properties
    // e.g. http://apps-api.uitzendinggemist.nl/episodes/AT_2049573.json
    public internal(set) var stills: [NPOStill]?
    public internal(set) var fragments: [NPOFragment]?
    public internal(set) var views = 0
    internal var online: NSDate?
    internal var offline: NSDate?
    
    override public var available: Bool {
        get {
            let restrictionOkay = restriction?.available ?? true
            return !self.revoked && self.active && self.isOnline() && restrictionOkay
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        stills <- map["stills"]
        fragments <- map["fragments"]
        views <- map["views"]
        online <- (map["expected_online_at"], DateTransform())
        offline <- (map["expected_offline_at"], DateTransform())
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
