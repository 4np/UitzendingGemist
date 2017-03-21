//
//  String+Trim.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 21/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension String {
    public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
