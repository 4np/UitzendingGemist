//
//  NPOManager+Geo.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 13/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire

extension NPOManager {
    // Get the location by ip
    // see: https://freegeoip.net/json/
    public func getGeo(withCompletion completed: @escaping (_ geo: GEO?, _ error: NPOError?) -> Void = { geo, error in }) {
        let _ = self.fetchModel(ofType: GEO.self, fromURL: "\(transport)://freegeoip.net/json/", withCompletion: completed)
    }
}
