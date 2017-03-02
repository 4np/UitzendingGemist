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
    
    public var configuration: (name: String, shortName: String, type: NPOLiveType, cc: Bool, audioQuality: Int, audioChannel: String, videoQuality: Int, alternativeChannel: NPOLive?) {
        switch self {
        case .npo1:
            return (name: "npo1", shortName: "ned1", type: .tv, cc: false, audioQuality: 128000, audioChannel: "audio", videoQuality: 1400000, alternativeChannel: nil)
        case .npo2:
            return (name: "npo2", shortName: "ned2", type: .tv, cc: false, audioQuality: 128000, audioChannel: "audio_1", videoQuality: 1400000, alternativeChannel: nil)
        case .npo3:
            return (name: "npo3", shortName: "ned3", type: .tv, cc: false, audioQuality: 128000, audioChannel: "audio", videoQuality: 1400000, alternativeChannel: .zappelin)
        case .npo1SDH:
            return (name: "npo1", shortName: "ned1", type: .tv, cc: true, audioQuality: 128000, audioChannel: "dut", videoQuality: 1000000, alternativeChannel: nil)
        case .npo2SDH:
            return (name: "npo2", shortName: "ned2", type: .tv, cc: true, audioQuality: 128000, audioChannel: "audio_nl", videoQuality: 200000, alternativeChannel: nil)
        case .npo3SDH:
            return (name: "npo3", shortName: "ned3", type: .tv, cc: true, audioQuality: 128000, audioChannel: "audio_nl", videoQuality: 200000, alternativeChannel: nil)
        case .zappelin:
            return (name: "zappelin24", shortName: "ned3", type: .thema, cc: false, audioQuality: 128000, audioChannel: "audio", videoQuality: 1000000, alternativeChannel: nil)
        case .zappxtra:
            return (name: "zappxtra", shortName: "opvo", type: .thema, cc: false, audioQuality: 64000, audioChannel: "audio_1", videoQuality: 1000000, alternativeChannel: nil)
        case .nieuws:
            return (name: "journaal24", shortName: "nosj", type: .thema, cc: false, audioQuality: 64000, audioChannel: "audio_1", videoQuality: 1000000, alternativeChannel: nil)
        case .cultura:
            return (name: "cultura24", shortName: "cult", type: .thema, cc: false, audioQuality: 64000, audioChannel: "audio_1", videoQuality: 1000000, alternativeChannel: nil)
        case .npo101:
            return (name: "101tv", shortName: "_101_", type: .thema, cc: false, audioQuality: 64000, audioChannel: "audio_1", videoQuality: 1000000, alternativeChannel: nil)
        case .politiek:
            return (name: "politiek24", shortName: "po24", type: .thema, cc: false, audioQuality: 128000, audioChannel: "audio_1", videoQuality: 1000000, alternativeChannel: nil)
        case .best:
            return (name: "best24", shortName: "hilv", type: .thema, cc: false, audioQuality: 64000, audioChannel: "audio_1", videoQuality: 1000000, alternativeChannel: .zappxtra)
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
            
            // old url (before 20170301):
            // let url = "http://ida.omroep.nl/odi/?prid=\(mid)&puboptions=h264_bb,h264_sb,h264_std&adaptive=no&part=1&token=\(token)"
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
    
    internal func getLiveVideoStreamURL(forURL url: URL?, andLiveChannel channel: NPOLive?, withCompletion completed: @escaping (_ url: URL?, _ error: NPOError?) -> Void = { url, error in }) {
        guard let url = url else {
            completed(nil, NPOError.networkError("NPOStream does not have a url (2)"))
            return
        }
        
        // example content of url:
        // setSource("http:\/\/l2cme608adc6090058b7eb9f000000.d4ec18219f11558f.smoote1f.npostreaming.nl\/d\/live\/npo\/tvlive\/npo1\/npo1.isml\/npo1.m3u8")
        
        let _ = Alamofire.request(url, headers: self.getHeaders()).responseString { response in
            //DDLogDebug("response: \(response.result.value)")
            guard let value = response.result.value, let channel = channel else {
                var error = NPOError.networkError("Could not fetch live stream url (url: \(url)) (1)")
                if let responseError = response.error {
                    error = NPOError.networkError("Could not fetch live stream url (\(responseError.localizedDescription)) (2)")
                }
                completed(nil, error)
                return
            }
            
            // remove crap to obtain the url
            let cleanedValue = value
                .replacingOccurrences(of: "setSource(\"", with: "")
                .replacingOccurrences(of: "\")", with: "")
                .replacingOccurrences(of: "\\", with: "")
            
            // At this stage we have a low quality 576p stream
            let lowQualityStreamURL = URL(string: cleanedValue)
            DDLogDebug("stream url: \(lowQualityStreamURL)")
            completed(lowQualityStreamURL, nil)
            return
            
//            // Modify the 576p stream url to direct to a high quality stream for better quality playback
//            //
//            // example cleaned url              : http://l2cm813037b8fe0058b7feb7000000.7af1f976c96a19cc.smoote2k.npostreaming.nl/d/live/npo/tvlive/npo1/npo1.isml/npo1.m3u8
//            // example high quality url         : http://l2cm813037b8fe0058b7feb7000000.7af1f976c96a19cc.smoote2k.npostreaming.nl/d/live/npo/tvlive/npo1/npo1.isml/npo1-audio=128000-video=1400000.m3u8
//            // example closed captioning url    : http://l2cm866bddee180058b89cac000000.9d4ca24fb84b31b1.smoote1e.npostreaming.nl/d/live/npo/tvlive/npo1cc/npo1cc.isml/npo1cc-dut=128000-video=100000.m3u8
//            
//            // remove the trailing .m3u8
//            var highQualityValue = cleanedValue.replacingOccurrences(of: ".m3u8", with: "")
//            
//            // add audio and video quality
//            highQualityValue += "\(channel.configuration.audioChannel)=\(channel.configuration.audioQuality)-video=\(channel.configuration.videoQuality).m3u8"
//            
//            //DDLogDebug("channel: \(channel), live stream url: \(highQualityValue)")
//            
//            guard let liveStreamURL = URL(string: highQualityValue) else {
//                completed(nil, NPOError.networkError("Could not fetch live stream url (url: \(url)) (3)"))
//                return
//            }
//            
//            completed(liveStreamURL, nil)
        }
    }
}
