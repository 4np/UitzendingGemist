//
//  NPOManager+Token.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire

extension NPOManager {
    
    internal func fetchToken(withCompletion completed: (token: String?, error: NPOError?) -> () = { token, error in }) {
        let url = "http://ida.omroep.nl/npoplayer/i.js"
        
        Alamofire.request(.GET, url, headers: getHeaders())
            .responseString { [weak self] response in
                switch response.result {
                    case .Success(let value):
                        self?.extractToken(fromJavascript: value, completed: completed)
                        break
                    case .Failure(let error):
                        completed(token: nil, error: .NetworkError(error.localizedDescription))
                        break
                }
            }
    }
    
    internal func extractToken(fromJavascript script: String, completed: (token: String?, error: NPOError?) -> () = { token, error in }) {
        do {
            let regex = try NSRegularExpression(pattern: "\"(.*)\"", options: NSRegularExpressionOptions.CaseInsensitive)
            let matches = regex.matchesInString(script, options: [], range: NSRange(location: 0, length: script.characters.count))
            
            guard let range = matches.first?.rangeAtIndex(1) else {
                completed(token: nil, error: NPOError.TokenError("Could not extract token as the pattern was not found"))
                return
            }
            
            let swiftRange = script.startIndex.advancedBy(range.location) ..< script.startIndex.advancedBy(range.location + range.length)
            let token = script.substringWithRange(swiftRange)
            
            completed(token: self.fix(token: token), error: nil)
        } catch let error as NSError {
            completed(token: nil, error: .TokenError(error.localizedDescription))
        }
    }
    
    internal func fix(token token: String) -> String {
        let minIndex = 4
        let maxIndex = token.characters.count - 4
        let matches = token.characters.enumerate()
            .filter { Int("\($0.element)") != nil && $0.index > minIndex && $0.index < maxIndex }
        
        // Make sure we have 2 or more matches
        guard matches.count >= 2 else {
            return token
        }
        
        // Swap the first two characters
        var characters = Array(token.characters)
        characters[matches[0].index] = matches[1].element
        characters[matches[1].index] = matches[0].element
        
        // Return the modified token
        return String(characters)
    }
}
