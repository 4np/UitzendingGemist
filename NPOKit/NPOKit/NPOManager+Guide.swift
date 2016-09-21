//
//  NPOManager+Guide.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 21/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

extension NPOManager {
    // http://apps-api.uitzendinggemist.nl/guide/2016-07-21.json
    public func getGuides(forChannels channels: [NPOLive], onDate date: Date, withCompletion completed: @escaping (_ guides: [NPOLive: [NPOBroadcast]]?, _ errors: [NPOLive: NPOError]?) -> () = { guides, errors in }) {
        var guides = [NPOLive: [NPOBroadcast]]()
        var errors = [NPOLive: NPOError]()

        // use the formatted npo date (which takes 06:00 am in the morning
        // into account)
        let formattedDate = date.formattedNPODate
        
        // create a dispatch group
        let group = DispatchGroup()
        
        // iterate over channels
        for channel in channels {
            group.enter()
            
            let path = channel.configuration.type == .TV ? "guide/\(formattedDate).json" : "guide/thema/\(formattedDate).json"
            let keypath = channel.configuration.shortName

            let _ = self.fetchModels(ofType: NPOBroadcast.self, fromPath: path, withKeyPath: keypath) { broadcasts, error in
                if let broadcasts = broadcasts {
                    guides[channel] = broadcasts
                } else if let error = error {
                    errors[channel] = error
                }
                
                group.leave()
            }
        }
        
        // done
        group.notify(queue: DispatchQueue.main) {
            completed(guides.count > 0 ? guides : nil, errors.count > 0 ? errors : nil)
        }
    }
}
