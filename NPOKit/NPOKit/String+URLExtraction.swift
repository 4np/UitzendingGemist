//
//  String+URLExtraction.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 21/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import CocoaLumberjack

extension String {
    public func extractURL() -> URL? {
        let pattern = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+([-a-zA-Z0-9@:%_\\+.~#?&//=]*)"
        
        // unescape special characters
        let unescaped = self.replacingOccurrences(of: "\\", with: "")
        
        if let range = unescaped.range(of: pattern, options: .regularExpression) {
            let url = unescaped.substring(with: range)
            return URL(string: url)
        }
        
        return nil
    }
}
