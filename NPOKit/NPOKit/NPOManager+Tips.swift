//
//  NPOManager+Tips.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension NPOManager {
    
    // http://apps-api.uitzendinggemist.nl/tips.json
    public func getTips(withCompletion completed: (programs: [NPOTip]?, error: NPOError?) -> () = { tips, error in }) {
        self.fetchModels(ofType: NPOTip.self, fromPath: "tips.json", withCompletion: completed)
    }
}
