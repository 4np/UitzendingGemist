//
//  Mappable+CustomDebugStringConvertible.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import ObjectMapper

extension Mappable where Self: CustomDebugStringConvertible {
    // MARK: CustomDebugStringConvertible
    
    public var debugDescription: String {
        let className = String(describing: type(of: self))
        
        guard let json = Mapper().toJSONString(self, prettyPrint: true) else {
            return className
        }
        
        return "\(className): \(json)"
    }
}
