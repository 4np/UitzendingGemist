//
//  NPOTip.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

// Equatable
// swiftlint:disable operator_whitespace
public func ==(lhs: NPOTip, rhs: NPOTip) -> Bool {
    guard let le = lhs.episode, let re = rhs.episode, le == re else {
        return false
    }
    
    return true
}
// swiftlint:enable operator_whitespace

extension Array where Element: NPOTip {
    func contains(_ tip: NPOTip) -> Bool {
        return self.index(where: { $0 == tip }) != nil
    }
}

open class NPOTip: NPOImage, Equatable {
    // https://apps-api.uitzendinggemist.nl/tips.json
    open fileprivate(set) var name: String?
    open fileprivate(set) var description: String?
    open fileprivate(set) var episode: NPOEpisode?
    open fileprivate(set) var published: Date?
    open fileprivate(set) var position: Int?
    
    open var publishedDisplayValue: String {
        guard let published = self.published else {
            return NPOConstants.unknownText
        }
        
        return published.daysAgoDisplayValue
    }
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: Mapping
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        name <- map["name"]
        description <- map["description"]
        episode <- map["episode"]
        published <- (map["published_at"], DateTransform())
        position <- map["position"]
    }
    
    // MARK: Video Stream
    
    open func getVideoStream(withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        guard let episode = self.episode else {
            completed(nil, .noEpisodeError)
            return
        }
        
        episode.getVideoStream(withCompletion: completed)
    }
    
    // MARK: Image fetching

    internal override func getImageURLs(withCompletion completed: @escaping (_ urls: [URL]) -> Void = { urls in }) -> Request? {
        var urls = [URL]()
        
        // tip image
        if let url = self.imageURL {
            urls.append(url as URL)
        }
        
        // episode image
        if let url = self.episode?.imageURL {
            urls.append(url as URL)
        }
        
        // program image
        if let url = self.episode?.program?.imageURL {
            urls.append(url as URL)
        }
        
        completed(urls)
        return nil
    }
}
