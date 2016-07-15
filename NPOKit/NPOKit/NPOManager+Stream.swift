//
//  NPOManager+Stream.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack

extension NPOManager {

    internal func getVideoStream(forMID mid: String?, withCompletion completed: (url: NSURL?, error: NPOError?) -> () = { url, error in }) {
        guard let mid = mid else {
            completed(url: nil, error: .NoMIDError)
            return
        }
        
        self.getToken() { [weak self] token, error in
            guard let token = token else {
                completed(url: nil, error: error)
                return
            }
            
            let url = "http://ida.omroep.nl/odi/?prid=\(mid)&puboptions=h264_bb,h264_sb,h264_std&adaptive=no&part=1&token=\(token)"
            
            self?.fetchModel(ofType: NPOStream.self, fromURL: url) { url, error in
                guard let url = url?.getStreamURL(forType: NPOStreamURLType.best) else {
                    completed(url: nil, error: error)
                    return
                }
                
                self?.getVideoStreamLocation(forURL: url, withCompletion: completed)
            }
        }
    }
    
    private func getVideoStreamLocation(forURL url: NSURL, withCompletion completed: (url: NSURL?, error: NPOError?) -> () = { url, error in }) {
        self.fetchModel(ofType: NPOStreamLocation.self, fromURL: url.absoluteString) { streamLocation, error in
            completed(url: streamLocation?.url, error: error)
        }
    }
}
