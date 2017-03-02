//
//  NPOStream.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper

public enum NPOStreamQuality: String {
    case high = "Hoog"
    case normal = "Normaal"
    case low = "Laag"
}

open class NPOStream: Mappable, CustomDebugStringConvertible {
    public private(set) var quality: NPOStreamQuality?
    public private(set) var contentType: String?
    public private(set) var format: String?
    // example: http://odi.omroep.nl/video/ida/h264_std/40dbe746de647f8d5418125a923c6510/58b7d7f0/VPWON_1236166/1?type=jsonp&callback=?
    private var jsonpURL: URL?
    
    private var url: URL? {
        guard let url = jsonpURL else { return nil }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil
        
        return components?.url
    }
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        quality <- map["label"]
        contentType <- map["contentType"]
        format <- map["format"]
        jsonpURL <- (map["url"], URLTransform())
    }
    
    // MARK: Get video url
    
    internal func getVideoStreamURL(withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        guard let url = self.url else {
            completed(nil, NPOError.networkError("NPOStream does not have a url"))
            return
        }
        
        let _ = NPOManager.sharedInstance.fetchModel(ofType: NPOStreamResource.self, fromURL: url.absoluteString) { streamResource, error in
            guard let streamURL = streamResource?.url else {
                let error = error ?? NPOError.networkError("Could not fetch stream resource (url: \(url))")
                completed(nil, error)
                return
            }
            
            completed(streamURL, nil)
        }

    }
}
