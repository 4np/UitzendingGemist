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

public class NPOImage: Mappable, CustomDebugStringConvertible {
    private var completionDelay = Int64(0.001)
    internal var imageURL: NSURL?

    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        imageURL <- (map["image"], URLTransform())
    }
    
    //MARK: Image cache identifier
    
    final internal func getImageIdentifier() -> String? {
        return self.getImageIdentifier(forSize: nil)
    }
    
    internal func getImageIdentifier(forSize size: CGSize?) -> String? {
        guard let url = self.imageURL?.absoluteString else {
            return nil
        }
        
        let components = url.componentsSeparatedByString("/")
        
        guard components.count > 3 else {
            return nil
        }
        
        var identifier = components[components.count - 3 ..< components.count].joinWithSeparator("-").stringByReplacingOccurrencesOfString(".jpg", withString: "")
        
        if let size = size {
            identifier += "_\(size.width)-\(size.height)"
        }
        
        return identifier
    }
    
    //MARK: Image fetching
    
    final public func getImage(withCompletion completed: (image: UIImage?, error: NPOError?, request: NPORequest) -> () = { image, error, request in }) -> NPORequest {
        let npoRequest = NPORequest()
        let identifier = self.getImageIdentifier()

        // caching
        if let identifier = identifier, cachedImage = NPOManager.sharedInstance.imageCache.imageWithIdentifier(identifier) {
            //DDLogDebug("use image from cache with identifier '\(identifier)' (\(cachedImage))")
            
            // delayed completion as we need the request to return first
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.completionDelay), dispatch_get_main_queue()) {
                completed(image: cachedImage, error: nil, request: npoRequest)
            }
            
            return npoRequest
        }
        
        let urlRequest = self.getImageURLs() { urls in
            guard let url = urls.first else {
                completed(image: nil, error: .NoImageError, request: npoRequest)
                return
            }

            let imageRequest = NPOManager.sharedInstance.getImage(forURL: url) { image, error in
                // cache image
                if let image = image, identifier = identifier {
                    //DDLogDebug("cache image with identifier '\(identifier)'")
                    NPOManager.sharedInstance.imageCache.addImage(image, withIdentifier: identifier)
                }
                
                completed(image: image, error: error, request: npoRequest)
            }
            
            npoRequest.append(imageRequest)
        }
        
        npoRequest.append(urlRequest)
        return npoRequest
    }
    
    final public func getImage(ofSize size: CGSize, withCompletion completed: (image: UIImage?, error: NPOError?, request: NPORequest) -> () = { image, error, request in }) -> NPORequest {
        let npoRequest = NPORequest()
        let identifier = self.getImageIdentifier(forSize: size)
        
        // caching
        if let identifier = identifier, cachedImage = NPOManager.sharedInstance.imageCache.imageWithIdentifier(identifier) {
            //DDLogDebug("use image from cache with identifier '\(identifier)' (\(cachedImage))")
            
            // delayed completion as we need the request to return first
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.completionDelay), dispatch_get_main_queue()) {
                completed(image: cachedImage, error: nil, request: npoRequest)
            }
            
            return npoRequest
        }
        
        let urlRequest = self.getImageURLs() { urls in
            guard let url = urls.first else {
                completed(image: nil, error: .NoImageError, request: npoRequest)
                return
            }
            
            let imageRequest = NPOManager.sharedInstance.getImage(forURL: url, ofSize: size) { image, error in
                // cache image
                if let image = image, identifier = identifier {
                    //DDLogDebug("cache image with identifier '\(identifier)'")
                    NPOManager.sharedInstance.imageCache.addImage(image, withIdentifier: identifier)
                }
                
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
