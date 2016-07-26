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

public class NPORequest: Equatable {
    private let uuid = NSUUID()
    private var cancelled = false
    private var requests = [Request]()
    
    internal func append(request: Request?) {
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
        
        for request in self.requests.enumerate() {
            request.element.cancel()
        }
        
        self.requests = []
    }
}
