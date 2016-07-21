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

public enum NPOLive: String {
    case NED1 = "NED1"
    case NED2 = "NED2"
    case NED3 = "NED3"
    case NPO_101 = "NPO_101"
    case NPO_POLITIEK = "NPO_POLITIEK"
    case NPO_BEST = "NPO_BEST"
    case NPO_HOLLAND_DOC = "NPO_HOLLAND_DOC"
    case NPO_CULTURA = "NPO_CULTURA"
    case NPO_HUMOR = "NPO_HUMOR"
    case NPO_ZAPPELIN = "NPO_ZAPPELIN"
    
    public static let all = [NED1, NED2, NED3, NPO_101, NPO_POLITIEK, NPO_BEST, NPO_HOLLAND_DOC, NPO_CULTURA, NPO_HUMOR, NPO_ZAPPELIN]
    
    internal var configuration: (name: String, type: String, audioQuality: Int, audioStream: String, videoQuality: Int) {
        switch self {
            case NED1:
                return (name: "ned1", type: "tvlive", audioQuality: 128000, audioStream: "", videoQuality: 1400000)
            case NED2:
                return (name: "ned2", type: "tvlive", audioQuality: 128000, audioStream: "_1", videoQuality: 1400000)
            case NED3:
                return (name: "ned3", type: "tvlive", audioQuality: 128000, audioStream: "", videoQuality: 1400000)
            case NPO_101:
                return (name: "101tv", type: "thematv", audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case NPO_POLITIEK:
                return (name: "politiek24", type: "thematv", audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case NPO_BEST:
                return (name: "best24", type: "thematv", audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case NPO_HOLLAND_DOC:
                return (name: "hollanddoc24", type: "thematv", audioQuality: 64000, audioStream: "", videoQuality: 1000000)
            case NPO_CULTURA:
                return (name: "cultura24", type: "thematv", audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case NPO_HUMOR:
                return (name: "humor24", type: "thematv", audioQuality: 64000, audioStream: "", videoQuality: 1000000)
            case NPO_ZAPPELIN:
                return (name: "zappelin24", type: "thematv", audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
        }
    }
}

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
    
    private func getVideoStreamLocation(forURL url: NSURL, withCompletion completed: (url: NSURL?, error: NPOError?) -> () = { url, error in }) -> Request? {
        return self.fetchModel(ofType: NPOStreamLocation.self, fromURL: url.absoluteString) { streamLocation, error in
            completed(url: streamLocation?.url, error: error)
        }
    }
    
    public func getVideoStream(forLiveChannel channel: NPOLive, withCompletion completed: (url: NSURL?, error: NPOError?) -> () = { url, error in }) {
        self.getToken() { [weak self] token, error in
            guard let token = token else {
                completed(url: nil, error: error)
                return
            }
            
            let configuration = channel.configuration
            let url = "http://ida.omroep.nl/aapi/?stream=http://livestreams.omroep.nl/live/npo/\(configuration.type)/\(configuration.name)/\(configuration.name).isml/\(configuration.name)-audio\(configuration.audioStream)=\(configuration.audioQuality)-video=\(configuration.videoQuality).m3u8&token=\(token)"
            
            self?.fetchModel(ofType: NPOLiveStream.self, fromURL: url) { liveStream, error in
                guard let url = liveStream?.url where liveStream?.success == true else {
                    completed(url: nil, error: error)
                    return
                }
                
                completed(url: url, error: nil)
            }
        }
    }
}
