//
//  NPOManager.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 13/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import CocoaLumberjack

public class NPOManager {
    public static let sharedInstance = NPOManager()
    
    public func test() {
        DDLogDebug("debug message inside NPOManager")
    }
}
