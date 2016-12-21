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
    
    internal func getToken(withCompletion completed: @escaping (_ token: String?, _ error: NPOError?) -> Void = { token, error in }) {
        let url = "http://ida.omroep.nl/npoplayer/i.js"
        
        Alamofire.request(url, headers: getHeaders())
            .responseString { [weak self] response in
                switch response.result {
                    case .success(let value):
                        self?.extractToken(fromJavascript: value, completed: completed)
                        break
                    case .failure(let error):
                        completed(nil, .networkError(error.localizedDescription))
                        break
                }
            }
    }
    
    internal func extractToken(fromJavascript script: String, completed: (_ token: String?, _ error: NPOError?) -> Void = { token, error in }) {
        do {
            let regex = try NSRegularExpression(pattern: "\"(.*)\"", options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: script, options: [], range: NSRange(location: 0, length: script.characters.count))
            
            guard let range = matches.first?.rangeAt(1) else {
                completed(nil, NPOError.tokenError("Could not extract token as the pattern was not found"))
                return
            }
            
            let swiftRange = script.characters.index(script.startIndex, offsetBy: range.location) ..< script.characters.index(script.startIndex, offsetBy: range.location + range.length)
            let token = script.substring(with: swiftRange)
            
            completed(self.fix(token: token), nil)
        } catch let error as NSError {
            completed(nil, .tokenError(error.localizedDescription))
        }
    }
    
    internal func fix(token: String) -> String {
        let minIndex = 4
        let maxIndex = token.characters.count - 4
        let matches = token.characters.enumerated().filter { Int("\($0.element)") != nil && $0.offset > minIndex && $0.offset < maxIndex }
        
        // Make sure we have 2 or more matches
        guard matches.count >= 2 else {
            return token
        }
        
        // Swap the first two characters
        var characters = Array(token.characters)
        characters[matches[0].offset] = matches[1].element
        characters[matches[1].offset] = matches[0].element
        
        // Return the modified token
        return String(characters)
    }
}
