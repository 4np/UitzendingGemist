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
    return lhs.episode?.mid == rhs.episode?.mid
}
// swiftlint:enable operator_whitespace

extension Array where Element: NPOTip {
    func contains(tip: NPOTip) -> Bool {
        return self.indexOf({ $0 == tip }) != nil
    }
}

public class NPOTip: NPOImage, Equatable {
    // http://apps-api.uitzendinggemist.nl/tips.json
    public private(set) var name: String?
    public private(set) var description: String?
    public private(set) var episode: NPOEpisode?
    public private(set) var published: NSDate?
    public private(set) var position: Int?
    
    public var publishedDisplayValue: String {
        get {
            guard let published = self.published else {
                return NPOConstants.unknownText
            }
            
            return published.daysAgoDisplayValue
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        name <- map["name"]
        description <- map["description"]
        episode <- map["episode"]
        published <- (map["published_at"], DateTransform())
        position <- map["position"]
    }
    
    //MARK: Video Stream
    
    public func getVideoStream(withCompletion completed: (url: NSURL?, error: NPOError?) -> () = { url, error in }) {
        guard let episode = self.episode else {
            completed(url: nil, error: .NoEpisodeError)
            return
        }
        
        episode.getVideoStream(withCompletion: completed)
    }
    
    //MARK: Image fetching
    
    internal override func getImageURLs(withCompletion completed: (urls: [NSURL]) -> () = { urls in }) -> Request? {
        var urls = [NSURL]()
        
        // tip image
        if let url = self.imageURL {
            urls.append(url)
        }
        
        // episode image
        if let url = self.episode?.imageURL {
            urls.append(url)
        }
        
        // program image
        if let url = self.episode?.program?.imageURL {
            urls.append(url)
        }
        
        completed(urls: urls)
        return nil
    }
}
