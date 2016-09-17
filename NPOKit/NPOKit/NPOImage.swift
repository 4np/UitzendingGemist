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

open class NPOImage: Mappable, CustomDebugStringConvertible {
    fileprivate var completionDelay = Int64(0.001)
    internal var imageURL: URL?

    //MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    //MARK: Mapping
    
    open func mapping(map: Map) {
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
        
        let components = url.components(separatedBy: "/")
        
        guard components.count > 3 else {
            return nil
        }
        
        var identifier = components[components.count - 3 ..< components.count].joined(separator: "-").replacingOccurrences(of: ".jpg", with: "")
        
        if let size = size {
            identifier += "_\(size.width)-\(size.height)"
        }
        
        return identifier
    }
    
    //MARK: Image fetching
    
    final public func getImage(withCompletion completed: @escaping (_ image: UIImage?, _ error: NPOError?, _ request: NPORequest) -> () = { image, error, request in }) -> NPORequest {
        let npoRequest = NPORequest()
        let identifier = self.getImageIdentifier()

        // caching
        if let identifier = identifier, let cachedImage = NPOManager.sharedInstance.imageCache.image(withIdentifier: identifier) {
            //DDLogDebug("use image from cache with identifier '\(identifier)' (\(cachedImage))")
            
            // delayed completion as we need the request to return first
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(self.completionDelay) / Double(NSEC_PER_SEC)) {
                completed(cachedImage, nil, npoRequest)
            }
            
            return npoRequest
        }
        
        let urlRequest = self.getImageURLs() { urls in
            guard let url = urls.first else {
                completed(nil, .noImageError, npoRequest)
                return
            }

            let imageRequest = NPOManager.sharedInstance.getImage(forURL: url) { image, error in
                // cache image
                if let image = image, let identifier = identifier {
                    //DDLogDebug("cache image with identifier '\(identifier)'")
                    NPOManager.sharedInstance.imageCache.add(image, withIdentifier: identifier)
                }
                
                completed(image, error, npoRequest)
            }
            
            npoRequest.append(imageRequest)
        }
        
        npoRequest.append(urlRequest)
        return npoRequest
    }
    
    final public func getImage(ofSize size: CGSize, withCompletion completed: @escaping (_ image: UIImage?, _ error: NPOError?, _ request: NPORequest) -> () = { image, error, request in }) -> NPORequest {
        let npoRequest = NPORequest()
        let identifier = self.getImageIdentifier(forSize: size)
        
        // caching
        if let identifier = identifier, let cachedImage = NPOManager.sharedInstance.imageCache.image(withIdentifier: identifier) {
            //DDLogDebug("use image from cache with identifier '\(identifier)' (\(cachedImage))")
            
            // delayed completion as we need the request to return first
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(self.completionDelay) / Double(NSEC_PER_SEC)) {
                completed(cachedImage, nil, npoRequest)
            }
            
            return npoRequest
        }
        
        let urlRequest = self.getImageURLs() { urls in
            guard let url = urls.first else {
                completed(nil, .noImageError, npoRequest)
                return
            }
            
            let imageRequest = NPOManager.sharedInstance.getImage(forURL: url, ofSize: size) { image, error in
                // cache image
                if let image = image, let identifier = identifier {
                    //DDLogDebug("cache image with identifier '\(identifier)'")
                    NPOManager.sharedInstance.imageCache.add(image, withIdentifier: identifier)
                }
                
                completed(image, error, npoRequest)
            }
            
            npoRequest.append(imageRequest)
        }
        
        npoRequest.append(urlRequest)
        return npoRequest
    }
    
    internal func getImageURLs(withCompletion completed: @escaping (_ urls: [URL]) -> () = { urls in }) -> Request? {
        var urls = [URL]()
        
        if let url = self.imageURL {
            urls.append(url)
        }
        
        completed(urls)
        return nil
    }
}
