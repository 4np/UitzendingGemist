//
//  GitHubRelease.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 20/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

// Not really NPO, but usefull nonetheless...
public class GitHubRelease: Mappable, CustomDebugStringConvertible {
    public internal(set) var tag: String?
    public internal(set) var url: NSURL?
    public internal(set) var zipball: NSURL?
    public internal(set) var tarball: NSURL?
    public internal(set) var prerelease: Bool = false
    public internal(set) var draft: Bool = false
    public internal(set) var details: String?
    
    public var version: String? {
        get {
            guard let tag = self.tag else {
                return nil
            }
            
            do {
                let regex = try NSRegularExpression(pattern: "([0-9.]+)", options: NSRegularExpressionOptions.CaseInsensitive)
                let matches = regex.matchesInString(tag, options: [], range: NSRange(location: 0, length: tag.characters.count))
                
                guard let range = matches.first?.rangeAtIndex(1) else {
                    return nil
                }
                
                let swiftRange = tag.startIndex.advancedBy(range.location) ..< tag.startIndex.advancedBy(range.location + range.length)
                return tag.substringWithRange(swiftRange)
            } catch let error as NSError {
                DDLogError("Could not extract version from GitHub tag '\(tag)' (\(error))")
                return nil
            }
        }
    }
    
    public var active: Bool {
        get {
            return !draft && !prerelease
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public func mapping(map: Map) {
        tag <- map["tag_name"]
        url <- (map["html_url"], URLTransform())
        zipball <- (map["zipball_url"], URLTransform())
        tarball <- (map["tarball_url"], URLTransform())
        prerelease <- map["prerelease"]
        draft <- map["draft"]
        details <- map["body"]
    }
}
