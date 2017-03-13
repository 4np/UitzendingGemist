//
//  NPOManager+Generics.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RealmSwift
import CocoaLumberjack

extension NPOManager {
    // MARK: Fetch Generic Models
    
    //internal func fetchModels<T: Object where T: Mappable, T: NPOResource>
    internal func fetchModels<T: Mappable>(ofType type: T.Type, fromPath path: String, withCompletion completed: @escaping (_ elements: [T]?, _ error: NPOError?) -> Void = { elements, error in }) -> Request? {
        return self.fetchModels(ofType: type, fromPath: path, withKeyPath: nil, withCompletion: completed)
    }
    
    internal func fetchModels<T: Mappable>(ofType type: T.Type, fromPath path: String, withKeyPath keyPath: String?, withCompletion completed: @escaping (_ elements: [T]?, _ error: NPOError?) -> Void = { elements, error in }) -> Request? {
        let url = self.getURL(forPath: path)
        return self.fetchModels(ofType: type, fromURL: url, withKeyPath: keyPath, withCompletion: completed)
    }
    
    internal func fetchModels<T: Mappable>(ofType type: T.Type, fromURL url: String, withKeyPath keyPath: String?, withCompletion completed: @escaping (_ elements: [T]?, _ error: NPOError?) -> Void = { elements, error in }) -> Request? {
        //DDLogDebug("fetch models of type \(type): \(url)")
        return Alamofire.request(url, headers: self.getHeaders())
            .responseArray(keyPath: keyPath) { (response: DataResponse<[T]>) in
                switch response.result {
                    case .success(let elements):
                        completed(elements, nil)
                        break
                    case .failure(let error):
                        completed(nil, .networkError(error.localizedDescription))
                        break
                }
        }
    }
    
    // MARK: Fetch Single Model
    
    internal func fetchModel<T: Mappable>(ofType type: T.Type, fromURL url: String, withCompletion completed: @escaping (_ element: T?, _ error: NPOError?) -> Void = { element, error in }) -> Request? {
        return self.fetchModel(ofType: type, fromURL: url, withKeyPath: nil, withCompletion: completed)
    }

    internal func fetchModel<T: Mappable>(ofType type: T.Type, fromPath path: String, withCompletion completed: @escaping (_ element: T?, _ error: NPOError?) -> Void = { element, error in }) -> Request? {
        return self.fetchModel(ofType: type, fromPath: path, withKeyPath: nil, withCompletion: completed)
    }
    
    internal func fetchModel<T: Mappable>(ofType type: T.Type, fromPath path: String, withKeyPath keyPath: String?, withCompletion completed: @escaping (_ element: T?, _ error: NPOError?) -> Void = { element, error in }) -> Request? {
        let url = self.getURL(forPath: path)
        return self.fetchModel(ofType: type, fromURL: url, withKeyPath: keyPath, withCompletion: completed)
    }
    
    internal func fetchModel<T: Mappable>(ofType type: T.Type, fromURL url: String, withKeyPath keyPath: String?, withCompletion completed: @escaping (_ element: T?, _ error: NPOError?) -> Void = { element, error in }) -> Request? {
        DDLogDebug("fetch model of type \(type): \(url)")
        return Alamofire.request(url, headers: self.getHeaders())
            .responseObject(keyPath: keyPath) { (response: DataResponse<T>) in
                switch response.result {
                    case .success(let element):
                        completed(element, nil)
                        break
                    case .failure(let error):
                        completed(nil, .networkError(error.localizedDescription))
                        break
                }
        }
    }
}
