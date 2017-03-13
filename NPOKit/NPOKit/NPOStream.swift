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
import CocoaLumberjack

public enum NPOStreamType: String {
    case live = "Live"
    case high = "Hoog"
    case normal = "Normaal"
    case low = "Laag"
}

open class NPOStream: Mappable, CustomDebugStringConvertible {
    public internal(set) var channel: NPOLive?
    public private(set) var type: NPOStreamType?
    public private(set) var contentType: String?
    public private(set) var format: String?
    // example: http://odi.omroep.nl/video/ida/h264_std/40dbe746de647f8d5418125a923c6510/58b7d7f0/VPWON_1236166/1?type=jsonp&callback=?
    private var rawURL: URL?
    
    private var url: URL? {
        guard let url = rawURL else { return nil }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil
        
        return components?.url
    }
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        type <- map["label"]
        contentType <- map["contentType"]
        format <- map["format"]
        rawURL <- (map["url"], URLTransform())
    }
    
    // MARK: Get video url
    
    internal func getVideoStreamURL(withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        guard let type = type else {
            completed(nil, NPOError.networkError("NPOStream does not have a type"))
            return
        }
        
        switch type {
            case .high, .normal, .low:
                self.getVideoStreamURL(forURL: url, withCompletion: completed)
            case .live:
                NPOManager.sharedInstance.getLiveVideoStreamURL(forURL: rawURL, withCompletion: completed)
        }
    }
    
    internal func getVideoStreamURL(forURL url: URL?, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        guard let url = url else {
            completed(nil, NPOError.networkError("NPOStream does not have a url (1)"))
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
