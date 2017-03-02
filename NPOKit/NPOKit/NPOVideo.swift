//
//  NPOVideo.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 02/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper

// Example response:
//
//{
//    "limited":false,
//    "site":null,
//    "items":[
//        [
//            {
//                "label":"Hoog",
//                "contentType":"odi",
//                "url":"http://odi.omroep.nl/video/ida/h264_std/cd303cede19617dbc93a888f54b9c83b/58b7439d/AT_2077064/1?type=jsonp&callback=?",
//                "format":"mp4"
//            },
//            {
//                "label":"Normaal",
//                "contentType":"odi",
//                "url":"http://odi.omroep.nl/video/ida/h264_bb/c76b0c85c08dc6dbb3ed6e450ea22764/58b7439d/AT_2077064/1?type=jsonp&callback=?",
//                "format":"mp4"
//            },
//            {
//                "label":"Laag",
//                "contentType":"odi",
//                "url":"http://odi.omroep.nl/video/ida/h264_sb/f95897882c52fa7189903251a8756edf/58b7439d/AT_2077064/1?type=jsonp&callback=?",
//                "format":"mp4"
//            }
//        ]
//    ]
//}
//
// Example response for live / themed streams:
//{
//    "limited": false,
//    "site": null,
//    "items": [
//        [
//            {
//                "label": "Live",
//                "contentType": "live",
//                "url": "http://livestreams.omroep.nl/live/npo/tvlive/npo2/npo2.isml/npo2.m3u8?hash=f545b16018eac4752d498dea4e5a0c58&type=jsonp&protection=url",
//                "format": "hls"
//            }
//        ]
//    ]
//}

open class NPOVideo: Mappable, CustomDebugStringConvertible {
    public private(set) var limited: Bool?
    public var site: String?
    public var streams: [NPOStream]?
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        limited <- map["limited"]
        site <- map["site"]
        streams <- map["items.0"]
    }
    
    // MARK: Convenience
    
    public var highestQualityStream: NPOStream? {
        // high
        if let stream = self.streams?.filter({ $0.type == .high }).first { return stream }
        // normal
        if let stream = self.streams?.filter({ $0.type == .normal }).first { return stream }
        // low
        if let stream = self.streams?.filter({ $0.type == .low }).first { return stream }
        // not really a quality, but the same back end returns live streams as well
        if let stream = self.streams?.filter({ $0.type == .live }).first { return stream }
        
        return nil
    }
}
