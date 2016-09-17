//
//  RealmEpisode.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 18/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift

class RealmEpisode: Object {
    dynamic var mid: String?
    dynamic var name: String?
    dynamic var info: String?           // description is a reserved word
    dynamic var program: RealmProgram?  // to-one relationship
    dynamic var broadcasted: Date?
    dynamic var duration: Int = 0
    dynamic var watchDuration: Int = 0
    dynamic var watched: Int = 0
    
    override static func indexedProperties() -> [String] {
        return ["mid"]
    }
}
