//
//  NPOManager+Image.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

extension NPOManager {
    internal func getImage(forURL url: URL?, withCompletion completed: @escaping (_ image: UIImage?, _ error: NPOError?) -> () = { image, error in }) -> Request? {
        guard let url = url else {
            completed(nil, .noImageError)
            return nil
        }
        
        let urlString = url.absoluteString

        return Alamofire.request(urlString, headers: self.getHeaders())
            .responseImage { response in
                switch response.result {
                    case .success(let image):
                        completed(image, nil)
                        break
                    case .failure(let error):
                        completed(nil, .networkError(error.localizedDescription))
                        break
                }
        }
    }
    
    internal func getImage(forURL url: URL?, ofSize size: CGSize, withCompletion completed: @escaping (_ image: UIImage?, _ error: NPOError?) -> () = { image, error in }) -> Request? {
        return self.getImage(forURL: url) { image, error in
            guard let image = image else {
                completed(nil, error)
                return
            }
            
            // scale image
            let imageFilter = AspectScaledToFillSizeFilter(size: size)
            completed(imageFilter.filter(image), nil)
        }
    }
}
