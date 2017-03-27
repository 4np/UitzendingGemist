//
//  NPOManager+Token.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack

extension NPOManager {
    internal func getToken(withCompletion completed: @escaping (_ token: String?, _ error: NPOError?) -> Void = { token, error in }) {
        // use cached token?
        if let token = self.token, !token.hasExpired {
            //DDLogDebug("Use cached token: \(token), age: \(token.age)")
            completed(token.token, nil)
            return
        }
        
        // refresh token
        let url = "https://ida.omroep.nl/app.php/auth"
        let _ = fetchModel(ofType: NPOToken.self, fromURL: url) { [weak self] token, error in
            //DDLogDebug("Refreshed token: \(token)")
            self?.token = token
            completed(token?.token, error)
        }
    }
}
