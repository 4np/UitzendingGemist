//
//  XCDYouTubeVideo+AVPlayer.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 18/11/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import AVKit
import CocoaLumberjack
import XCDYouTubeKit

// see http://www.genyoutube.net/formats-resolution-youtube-videos.html
enum YouTubeVideo: Int {
    // Main Stream Video Formats
    case main360p          = 18
    case main720p          = 22
    case main1080p         = 37
    case main4k            = 38 // 3072p
    
    // FLV
    case flv360p           = 34
    case flv480p           = 35
    
    // WEBM
    case webm360p          = 43
    case webm480p          = 44
    case webm720p          = 45
    case webm1080p         = 46
    
    // Apple HTTP Live Streaming (HLS)
    case hls360p           = 93
    case hls480p           = 94
    case hls720p           = 95
    case hls1080p          = 96
    
    // DASH mp4 video (no audio!)
    case dash360p          = 134
    case dash480p          = 135
    case dash720p          = 136
    case dash1080p         = 137
    
    // all qualities that can be played on Apple TV
    public static let playable = [
        main1080p, webm1080p, dash1080p,
        main720p, webm720p, dash720p,
        flv480p, webm480p, dash480p,
        main360p, flv360p, webm360p, dash360p
    ]
    
    public static let videoOnly = [dash1080p, dash720p, dash480p, dash360p]
}

enum YouTubeAudio: Int {
    // dash aac audio
    case aac48kbps         = 139
    case aac128kbps        = 140
    case aac256kbps        = 141
    
    // dash webm audio
    case webm128kbps       = 171
    case webm256kbps       = 172
    
    public static let audioOnly = [
        aac256kbps, webm256kbps,
        aac128kbps, webm128kbps,
        aac48kbps
    ]
}

extension XCDYouTubeVideo {
    
    // MARK: Swifty URLs
    
    fileprivate func getURLs() -> [Int: URL] {
        // transform streamURL dictionary
        var urls = [Int: URL]()
        
        for (itag, url) in streamURLs {
            if let key = itag as? Int {
                urls[key] = url.absoluteURL
            }
        }
        
        return urls
    }
    
    fileprivate func getStream() -> (quality: YouTubeVideo, url: URL)? {
        let urls = self.getURLs()
        
        for quality in YouTubeVideo.playable {
            if let url = urls[quality.rawValue] {
                //debugPrint("using --> \(quality)")
                return (quality: quality, url: url)
            }
        }
        
        return nil
    }
    
    fileprivate func getAudioURL() -> URL? {
        let urls = self.getURLs()
        
        for quality in YouTubeAudio.audioOnly {
            if let url = urls[quality.rawValue] {
                return url
            }
        }
        
        return nil
    }
    
    final public func getPlayerItem() -> AVPlayerItem? {
        // get the stream url
        guard let stream = getStream() else {
            return nil
        }
        
        guard YouTubeVideo.videoOnly.contains(stream.quality) else {
            // this is a stream containing both audio as well as video
            return AVPlayerItem(url: stream.url)
        }
        
        // this is a video only stream, so we need to create a combined player
        // that contains a video as well as an audio stream
        guard let audioURL = getAudioURL() else {
            return nil
        }
        
        // get composite player item (video + audio streams)
        do {
            return try getPlayerItem(forVideoURL: stream.url, audioURL: audioURL)
        } catch(let error) {
            DDLogError("Could not get player item (\(error))")
        }
        
        return nil
    }
    
    fileprivate func getPlayerItem(forVideoURL videoURL: URL, audioURL: URL) throws -> AVPlayerItem? {
        let composition = AVMutableComposition()
        
        // add video
        let videoAsset = AVURLAsset(url: videoURL)
        let videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo).first else {
            return nil
        }
        
        let composedVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        try composedVideoTrack.insertTimeRange(videoTimeRange, of: videoTrack, at: kCMTimeZero)
        
        // add audio
        let audioAsset = AVURLAsset(url: audioURL)
        let audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
        guard let audioTrack = audioAsset.tracks(withMediaType: AVMediaTypeAudio).first else {
            return nil
        }
        
        let composedAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        try composedAudioTrack.insertTimeRange(audioTimeRange, of: audioTrack, at: kCMTimeZero)
        
        // create player item for this composite audio and video stream
        let playerItem = AVPlayerItem(asset: composition)
        
        return playerItem
    }
}
