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

open class NPOMedia: NPOImage, Equatable {
    open internal(set) var mid: String? {
        didSet {
            midUpdated()
        }
    }
    //internal var neboID: String?
    open internal(set) var name: String?
    
    // MARK: Lifecycle

    required public init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: Mapping
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        mid <- map["mid"]
        //neboID <- map["nebo_id"]
        name <- map["name"]
    }
    
    // MARK: Image cache identifier
    
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
    
    // MARK: Video Stream
    
    open func getVideoStream(withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        NPOManager.sharedInstance.getVideoStream(forMID: mid, withCompletion: completed)
    }
    
    // MARK: Special methods
    
    internal func midUpdated() {
        // override to implement
    }
}
