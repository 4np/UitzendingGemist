//
//  String+Regex.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 22/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension String {
    func matches(forPattern pattern: String) -> [NSTextCheckingResult]? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let range = NSRange(location: 0, length: self.characters.count)
            return regex.matches(in: self, options: [], range: range)
        } catch {
            return nil
        }
    }
}
