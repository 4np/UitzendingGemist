//
//  NPOStreamResource.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 02/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import AlamofireImage
import ObjectMapper

// Example response:
//
//{
//    "errorcode": 0,
//    "family": "download",
//    "path": "/urishieldv2/l27m48ba626566e3a82d0058b7d9fe000000.96b2e29265ba3f889f98fb3648ee68b8/s00/ceresodi/h264/p/0d/10/10/3d/std_VPWON_1236166.m4v",
//    "protocol": "http",
//    "server": "content50c2b.omroep.nl",
//    "wait": 0,
//    "querystring": {
//        "odiredirecturl": "/video/ida/h264_std/d5bb64ff982034879beade261bb55426/58b7d9ce/VPWON_1236166/1"
//    },
//    "url": "http://content50c2b.omroep.nl/urishieldv2/l27m48ba626566e3a82d0058b7d9fe000000.96b2e29265ba3f889f98fb3648ee68b8/s00/ceresodi/h264/p/0d/10/10/3d/std_VPWON_1236166.m4v?odiredirecturl=%2Fvideo%2Fida%2Fh264_std%2Fd5bb64ff982034879beade261bb55426%2F58b7d9ce%2FVPWON_1236166%2F1"
//}

open class NPOStreamResource: Mappable, CustomDebugStringConvertible {
    public private(set) var url: URL?
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
    }
    
    // MARK: Mapping
    
    open func mapping(map: Map) {
        url <- (map["url"], URLTransform())
    }
}
