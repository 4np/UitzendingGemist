//
//  NPOImage.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper
import CocoaLumberjack

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
    
    final public func getImage(withCompletion completed: (image: UIImage?, error: NPOError?, request: NPORequest) -> () = { image, error, request in }) -> NPORequest {
        let npoRequest = NPORequest()
        
        let urlRequest = self.getImageURLs() { urls in
            guard let url = urls.first else {
                completed(image: nil, error: .NoImageError, request: npoRequest)
                return
            }

            let imageRequest = NPOManager.sharedInstance.getImage(forURL: url) { image, error in
                completed(image: image, error: error, request: npoRequest)
            }
            npoRequest.append(imageRequest)
        }
        
        npoRequest.append(urlRequest)
        return npoRequest
    }
    
    final public func getImage(ofSize size: CGSize, withCompletion completed: (image: UIImage?, error: NPOError?, request: NPORequest) -> () = { image, error, request in }) -> NPORequest {
        let npoRequest = NPORequest()
        
        let urlRequest = self.getImageURLs() { urls in
            guard let url = urls.first else {
                completed(image: nil, error: .NoImageError, request: npoRequest)
                return
            }
            
            let imageRequest = NPOManager.sharedInstance.getImage(forURL: url, ofSize: size) { image, error in
                completed(image: image, error: error, request: npoRequest)
            }
            npoRequest.append(imageRequest)
        }
        
        npoRequest.append(urlRequest)
        return npoRequest
    }
    
    internal func getImageURLs(withCompletion completed: (urls: [NSURL]) -> () = { urls in }) -> Request? {
        var urls = [NSURL]()
        
        if let url = self.imageURL {
            urls.append(url)
        }
        
        completed(urls: urls)
        return nil
    }
}
