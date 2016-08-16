//
//  NPOMedia.swift
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

// Equatable
// swiftlint:disable operator_whitespace
public func ==(lhs: NPOMedia, rhs: NPOMedia) -> Bool {
    return lhs.mid == rhs.mid
}
// swiftlint:enable operator_whitespace

public class NPOMedia: NPOImage, Equatable {
    public internal(set) var mid: String?
    //internal var neboID: String?
    public internal(set) var name: String?
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        mid <- map["mid"]
        //neboID <- map["nebo_id"]
        name <- map["name"]
    }
    
    //MARK: Image cache identifier
    
    override func getImageIdentifier(forSize size: CGSize?) -> String? {
        guard let mid = self.mid else {
            return nil
        }
        
        var identifier = mid
        
        if let size = size {
            identifier += "_\(size.width)-\(size.height)"
        }
        
        return identifier
    }
    
    //MARK: Video Stream
    
    public func getVideoStream(withCompletion completed: (url: NSURL?, error: NPOError?) -> () = { url, error in }) {
        NPOManager.sharedInstance.getVideoStream(forMID: mid, withCompletion: completed)
    }
}
