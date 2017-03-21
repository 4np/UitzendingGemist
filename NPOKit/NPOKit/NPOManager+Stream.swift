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
    case tv = "tvlive"
    case thema = "thematv"
}

public enum NPOLive: String {
    // live
    case npo1 = "LI_NL1_4188102"
    case npo2 = "LI_NL2_4188105"
    case npo3 = "LI_NL3_4188107"            // npo3 after 19:00
    
    // live - closed captioned with subtitles for the Deaf and Hard-of-Hearing (SDH)
    case npo1SDH = "LI_NL1_824154"
    case npo2SDH = "LI_NL2_824153"
    case npo3SDH = "LI_NL3_824151"
    
    // themed channels
    case zappelin = "LI_NEDERLAND3_136696"  // npo3 before 19:00
    case zappxtra = "LI_NEDERLAND3_221687"
    case nieuws = "LI_NEDERLAND1_221673"
    case cultura = "LI_NEDERLAND2_221679"
    case npo101 = "LI_NEDERLAND3_221683"
    case politiek = "LI_NEDERLAND1_221675"
    case best = "does-not-exist?"           // from 20:00 to 3:59 (zapp xtra??)
    
    public static let all = [npo1, npo2, npo3, zappxtra, npo101, nieuws, cultura, best, politiek]
    
    public var configuration: (name: String, shortName: String, type: NPOLiveType, alternativeChannel: NPOLive?) {
        switch self {
        case .npo1:
            return (name: "npo1", shortName: "ned1", type: .tv, alternativeChannel: nil)
        case .npo2:
            return (name: "npo2", shortName: "ned2", type: .tv, alternativeChannel: nil)
        case .npo3:
            return (name: "npo3", shortName: "ned3", type: .tv, alternativeChannel: .zappelin)
        case .npo1SDH:
            return (name: "npo1", shortName: "ned1", type: .tv, alternativeChannel: nil)
        case .npo2SDH:
            return (name: "npo2", shortName: "ned2", type: .tv, alternativeChannel: nil)
        case .npo3SDH:
            return (name: "npo3", shortName: "ned3", type: .tv, alternativeChannel: nil)
        case .zappelin:
            return (name: "zappelin24", shortName: "ned3", type: .thema, alternativeChannel: nil)
        case .zappxtra:
            return (name: "zappxtra", shortName: "opvo", type: .thema, alternativeChannel: nil)
        case .nieuws:
            return (name: "journaal24", shortName: "nosj", type: .thema, alternativeChannel: nil)
        case .cultura:
            return (name: "cultura24", shortName: "cult", type: .thema, alternativeChannel: nil)
        case .npo101:
            return (name: "101tv", shortName: "_101_", type: .thema, alternativeChannel: nil)
        case .politiek:
            return (name: "politiek24", shortName: "po24", type: .thema, alternativeChannel: nil)
        case .best:
            return (name: "best24", shortName: "hilv", type: .thema, alternativeChannel: .zappxtra)
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
            
            let url = "http://ida.omroep.nl/app.php/\(mid)?adaptive=yes&token=\(token)"
            //DDLogDebug("episode url -> \(url)")
            
            self?.getVideoStream(forURL: url, andLiveChannel: nil, withCompletion: completed)
        }
    }
    
    private func getVideoStream(forURL url: String, andLiveChannel liveChannel: NPOLive?, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        let _ = self.fetchModel(ofType: NPOVideo.self, fromURL: url) { video, error in
            guard let video = video else {
                let error = error ?? NPOError.networkError("Could not fetch video model (url: \(url))")
                completed(nil, error)
                return
            }
            
            // check if this video is limited (not sure what that really means, but
            // I assume it is most likely regionally limited)
            if let limited = video.limited, limited {
                DDLogWarn("The video is marked as (regionally?) *limited* and might not play? (video: \(video))")
            }
            
            // set live channel, if we know it
            video.channel = liveChannel
            
            guard let stream = video.highestQualityStream else {
                let error = error ?? NPOError.networkError("Could not fetch stream for video model (url: \(url))")
                completed(nil, error)
                return
            }
            
            stream.getVideoStreamURL(withCompletion: completed)
        }
    }
    
    public func getVideoStream(forLiveChannel channel: NPOLive, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        self.getToken { [weak self] token, error in
            guard let token = token else {
                completed(nil, error)
                return
            }
            
            // 1. http://ida.omroep.nl/app.php/LI_NL1_4188102?adaptive=yes&token=7t0akpumcsre8k9jqtrk0dblt7
            //    {
            //        "limited": false,
            //        "site": null,
            //        "items": [
            //        [
            //        {
            //        "label": "Live",
            //        "contentType": "live",
            //        "url": "http://livestreams.omroep.nl/live/npo/tvlive/npo1/npo1.isml/npo1.m3u8?hash=f9ec3c0d696b8fce324f9a58b5899978&type=jsonp&protection=url",
            //        "format": "hls"
            //        }
            //        ]
            //        ]
            //    }
            // 2. http://livestreams.omroep.nl/live/npo/tvlive/npo1/npo1.isml/npo1.m3u8?hash=f9ec3c0d696b8fce324f9a58b5899978&type=jsonp&protection=url
            //    setSource("http:\/\/l2cm10d0745c410058b7e13a000000.d6e09d487eeed2ac.smoote2k.npostreaming.nl\/d\/live\/npo\/tvlive\/npo1\/npo1.isml\/npo1.m3u8")

            let url = "http://ida.omroep.nl/app.php/\(channel.rawValue)?adaptive=yes&token=\(token)"
            //DDLogDebug("live url: \(url)")
            self?.getVideoStream(forURL: url, andLiveChannel: channel, withCompletion: completed)
        }
    }
    
    internal func getLiveVideoStreamURL(forURL url: URL?, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        guard let url = url else {
            completed(nil, NPOError.networkError("NPOStream does not have a url (2)"))
            return
        }
        
        let _ = Alamofire.request(url, headers: self.getHeaders()).responseString { response in
            //DDLogDebug("response: \(response.result.value)")
            guard let value = response.result.value else {
                var error = NPOError.networkError("Could not fetch live stream url (url: \(url)) (1)")
                if let responseError = response.error {
                    error = NPOError.networkError("Could not fetch live stream url (\(responseError.localizedDescription)) (2)")
                }
                completed(nil, error)
                return
            }
            
            //DDLogDebug("Value: \(value)")
            
            guard let adaptiveStreamURL = value.extractURL() else {
                completed(nil, NPOError.networkError("Could not fetch live stream url (url: \(url)) (3: \(value))"))
                return
            }
            //DDLogDebug("stream url: \(adaptiveStreamURL)")
            completed(adaptiveStreamURL, nil)
            return
        }
    }
}
