//
//  Mappable+CustomStringConvertible.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import ObjectMapper

extension Mappable where Self: CustomStringConvertible {
    //MARK: CustomDebugStringConvertible
    
    public var description: String {
        get {
            return String(describing: type(of: self))
        }
    }
}
