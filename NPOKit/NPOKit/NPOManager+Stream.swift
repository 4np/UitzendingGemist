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

public enum NPOLiveType: String {
    case TV = "tvlive"
    case THEMA = "thematv"
}

public enum NPOLive: String {
    case NPO_1
    case NPO_2
    case NPO_3
    case NPO_ZAPP_XTRA
    case NPO_101
    case NPO_NIEUWS
    case NPO_POLITIEK
    case NPO_BEST
    case NPO_CULTURA
//    case NPO_ZAPP = "NPO_ZAPP"
    
    public static let all = [NPO_1, NPO_2, NPO_3, NPO_ZAPP_XTRA, NPO_101, NPO_NIEUWS, NPO_POLITIEK, NPO_BEST, NPO_CULTURA]
    
    internal var configuration: (name: String, shortName: String, type: NPOLiveType, audioQuality: Int, audioStream: String, videoQuality: Int) {
        switch self {
            case .NPO_1:
                return (name: "ned1", shortName: "ned1", type: .TV, audioQuality: 128000, audioStream: "", videoQuality: 1400000)
            case .NPO_2:
                return (name: "ned2", shortName: "ned2", type: .TV, audioQuality: 128000, audioStream: "_1", videoQuality: 1400000)
            case .NPO_3:
                return (name: "ned3", shortName: "ned3", type: .TV, audioQuality: 128000, audioStream: "", videoQuality: 1400000)
            case .NPO_ZAPP_XTRA:
                return (name: "zappelin24", shortName: "opvo", type: .THEMA, audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case .NPO_101:
                return (name: "101tv", shortName: "_101_", type: .THEMA, audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case .NPO_NIEUWS:
                return (name: "journaal24", shortName: "nosj", type: .THEMA, audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case .NPO_POLITIEK:
                return (name: "politiek24", shortName: "po24", type: .THEMA, audioQuality: 128000, audioStream: "_1", videoQuality: 1000000)
            case .NPO_BEST:
                return (name: "best24", shortName: "hilv", type: .THEMA, audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
            case .NPO_CULTURA:
                return (name: "cultura24", shortName: "cult", type: .THEMA, audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
//            case NPO_ZAPP_XTRA:
//                return (name: "zapp", shortName: "ned1", type: .THEMA, audioQuality: 64000, audioStream: "_1", videoQuality: 1000000)
        }
    }
}

extension NPOManager {
    internal func getVideoStream(forMID mid: String?, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        guard let mid = mid else {
            completed(nil, .noMIDError)
            return
        }
        
        self.getToken { [weak self] token, error in
            guard let token = token else {
                completed(nil, error)
                return
            }
            
            let url = "http://ida.omroep.nl/odi/?prid=\(mid)&puboptions=h264_bb,h264_sb,h264_std&adaptive=no&part=1&token=\(token)"
            
            let _ = self?.fetchModel(ofType: NPOStream.self, fromURL: url) { url, error in
                guard let url = url?.getStreamURL(forType: NPOStreamURLType.best) else {
                    completed(nil, error)
                    return
                }
                
                let _ = self?.getVideoStreamLocation(forURL: url, withCompletion: completed)
            }
        }
    }
    
    fileprivate func getVideoStreamLocation(forURL url: URL, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) -> Request? {
        return self.fetchModel(ofType: NPOStreamLocation.self, fromURL: url.absoluteString) { streamLocation, error in
            completed(streamLocation?.url, error)
        }
    }
    
    public func getVideoStream(forLiveChannel channel: NPOLive, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        self.getToken { [weak self] token, error in
            guard let token = token else {
                completed(nil, error)
                return
            }
            
            let configuration = channel.configuration
            let url = "http://ida.omroep.nl/aapi/?stream=http://livestreams.omroep.nl/live/npo/\(configuration.type.rawValue)/\(configuration.name)/\(configuration.name).isml/\(configuration.name)-audio\(configuration.audioStream)=\(configuration.audioQuality)-video=\(configuration.videoQuality).m3u8&token=\(token)"
            
            let _ = self?.fetchModel(ofType: NPOLiveStream.self, fromURL: url) { liveStream, error in
                guard let url = liveStream?.url, liveStream?.success == true else {
                    completed(nil, error)
                    return
                }
                
                completed(url as URL, nil)
            }
        }
    }
}
