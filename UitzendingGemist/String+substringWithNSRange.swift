//
//  String+substringWithNSRange.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 22/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                       length: utf16.distance(from: from, to: to))
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    func substring(withNSRange nsRange: NSRange) -> String? {
        guard let range = range(from: nsRange) else { return nil }
        return substring(with: range)
    }
    
    func substring(withNSRange nsRange: NSRange, stripPattern pattern: String) -> String? {
        return substring(withNSRange: nsRange)?.replacingOccurrences(of: pattern, with: "", options: [.regularExpression], range: nil)
    }
}
