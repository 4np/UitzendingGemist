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
    final public func getImage(forURL url: NSURL?, withCompletion completed: (image: UIImage?, error: NPOError?) -> () = { image, error in }) -> Request? {
        guard let url = url else {
            completed(image: nil, error: .NoImageError)
            return nil
        }

        return Alamofire.request(.GET, url, headers: self.getHeaders())
            .responseImage { response in
                switch response.result {
                    case .Success(let image):
                        completed(image: image, error: nil)
                        break
                    case .Failure(let error):
                        completed(image: nil, error: .NetworkError(error.localizedDescription))
                        break
                }
        }
    }
    
    final public func getImage(forURL url: NSURL?, ofSize size: CGSize, withCompletion completed: (image: UIImage?, error: NPOError?) -> () = { image, error in }) -> Request? {
        return self.getImage(forURL: url) { image, error in
            guard let image = image else {
                completed(image: nil, error: error)
                return
            }
            
            // scale image
            let imageFilter = AspectScaledToFillSizeFilter(size: size)
            completed(image: imageFilter.filter(image), error: nil)
        }
    }
}
