//
//  NPOImage.swift
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

public class NPOImage: Mappable, CustomDebugStringConvertible {
    internal var imageURL: NSURL?
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        imageURL <- (map["image"], URLTransform())
    }
    
    //MARK: Image fetching
    
    public func getImage(withCompletion completed: (image: UIImage?, error: NPOError?) -> () = { image, error in }) {
        NPOManager.sharedInstance.getImage(forURL: self.imageURL, withCompletion: completed)
    }
    
    public func getImage(ofSize size: CGSize, withCompletion completed: (image: UIImage?, error: NPOError?) -> () = { image, error in }) {
        NPOManager.sharedInstance.getImage(forURL: self.imageURL, ofSize: size, withCompletion: completed)
    }
}
