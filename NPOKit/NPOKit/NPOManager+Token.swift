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
        // old url (before 20170301): http://ida.omroep.nl/npoplayer/i.js
        let url = "http://ida.omroep.nl/app.php/auth"
        
        Alamofire.request(url, headers: getHeaders()).responseJSON { [weak self] response in
            switch response.result {
                case .success(let responseJSON):
                    // as of 20170301 the token does not appear to require fixing?
                    guard let json = responseJSON as? [String: Any], let token = json["token"] as? String else {
                        completed(nil, .networkError("Could not fetch token from json (\(responseJSON))"))
                        return
                    }

                    //{"token":"992a564t1q555prq5jqkb2fm33"}
                    //http://ida.omroep.nl/app.php/AT_2077064?adaptive=yes&token=992a564t1q555prq5jqkb2fm33
                    
                    completed(token, nil)
                case .failure(let error):
                    completed(nil, .networkError(error.localizedDescription))
            }

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
