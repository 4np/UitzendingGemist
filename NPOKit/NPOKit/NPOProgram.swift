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
import RealmSwift
import CocoaLumberjack

public class NPOProgram: NPORestrictedMedia {
    // program specific properties
    // e.g. http://apps-api.uitzendinggemist.nl/episodes/AT_2049573.json
    internal var online: NSDate?
    internal var offline: NSDate?
    
    public var firstLetter: String? {
        guard let char = self.name?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.first else {
            return nil
        }
        
        let letter = "\(char)".lowercaseString
        
        if let _ = Int(letter) {
            return "#"
        } else {
            return letter
        }
    }
    
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
    
    //MARK: Realm
    
    lazy internal var realmProgram: RealmProgram? = {
        do {
            let realm = try Realm()
            
            // get first instance by mid
            guard let mid = self.mid, program = realm.objects(RealmProgram).filter("mid = '\(mid)'").first else {
                // create a new instance
                let program = RealmProgram()
                program.mid = self.mid
                program.name = self.name
                program.firstLetter = self.firstLetter
                program.favorite = false
                
                // add program to realm
                try realm.write {
                    realm.add(program)
                }
                
                return program
            }
            
            return program
        } catch let error as NSError {
            DDLogError("Could not fetch program from realm (\(error.localizedDescription))")
            return nil
        }
    }()
    
    //MARK: Favoriting
    
    public var favorite: Bool {
        get {
            return self.realmProgram?.favorite ?? false
        }
        set {
            do {
                let realm = try Realm()
                
                try realm.write {
                    self.realmProgram?.favorite = newValue
                }
            } catch let error as NSError {
                DDLogError("Could not write program to realm (\(error.localizedDescription))")
            }
        }
    }
    
    public func toggleFavorite() {
        favorite = !favorite
    }
}
