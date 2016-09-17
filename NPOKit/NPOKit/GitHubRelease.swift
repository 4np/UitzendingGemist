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
open class GitHubRelease: Mappable, CustomDebugStringConvertible {
    open internal(set) var tag: String?
    open internal(set) var url: URL?
    open internal(set) var zipball: URL?
    open internal(set) var tarball: URL?
    open internal(set) var prerelease: Bool = false
    open internal(set) var draft: Bool = false
    open internal(set) var details: String?
    
    open var version: String? {
        get {
            guard let tag = self.tag else {
                return nil
            }
            
            do {
                let regex = try NSRegularExpression(pattern: "([0-9.]+)", options: NSRegularExpression.Options.caseInsensitive)
                let matches = regex.matches(in: tag, options: [], range: NSRange(location: 0, length: tag.characters.count))
                
                guard let range = matches.first?.rangeAt(1) else {
                    return nil
                }
                
                let swiftRange = tag.characters.index(tag.startIndex, offsetBy: range.location) ..< tag.characters.index(tag.startIndex, offsetBy: range.location + range.length)
                return tag.substring(with: swiftRange)
            } catch let error as NSError {
                DDLogError("Could not extract version from GitHub tag '\(tag)' (\(error))")
                return nil
            }
        }
    }
    
    open var active: Bool {
        get {
            return !draft && !prerelease
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    open func mapping(map: Map) {
        tag <- map["tag_name"]
        url <- (map["html_url"], URLTransform())
        zipball <- (map["zipball_url"], URLTransform())
        tarball <- (map["tarball_url"], URLTransform())
        prerelease <- map["prerelease"]
        draft <- map["draft"]
        details <- map["body"]
    }
}
