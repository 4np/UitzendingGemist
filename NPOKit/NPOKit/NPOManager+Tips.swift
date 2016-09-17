//
//  NPOManager+Tips.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire

extension NPOManager {    
    // http://apps-api.uitzendinggemist.nl/tips.json
    public func getTips(withCompletion completed: @escaping (_ tips: [NPOTip]?, _ error: NPOError?) -> () = { tips, error in }) -> Request? {
        return self.fetchModels(ofType: NPOTip.self, fromPath: "tips.json", withCompletion: completed)
    }
}
