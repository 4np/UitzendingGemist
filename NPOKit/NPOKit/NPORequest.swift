//
//  NPORequest.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 18/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire

// Equatable
// swiftlint:disable operator_whitespace
public func ==(lhs: NPORequest, rhs: NPORequest) -> Bool {
    return lhs.uuid == rhs.uuid
}
// swiftlint:enable operator_whitespace

open class NPORequest: Equatable {
    fileprivate let uuid = UUID()
    fileprivate var cancelled = false
    fileprivate var requests = [Request]()
    
    internal func append(_ request: Request?) {
        guard let request = request else {
            return
        }
        
        if cancelled {
            // cancel future requests
            request.cancel()
        } else {
            self.requests.append(request)
        }
    }
    
    final public func cancel() {
        self.cancelled = true
        
        for request in self.requests.enumerated() {
            request.element.cancel()
        }
        
        self.requests = []
    }
}
