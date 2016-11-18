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
    case main_360p          = 18
    case main_720p          = 22
    case main_1080p         = 37
    case main_4k            = 38 // 3072p
    
    // FLV
    case flv_360p           = 34
    case flv_480p           = 35
    
    // WEBM
    case webm_360p          = 43
    case webm_480p          = 44
    case webm_720p          = 45
    case webm_1080p         = 46
    
    // Apple HTTP Live Streaming (HLS)
    case hls_360p           = 93
    case hls_480p           = 94
    case hls_720p           = 95
    case hls_1080p          = 96
    
    // DASH mp4 video (no audio!)
    case dash_360p          = 134
    case dash_480p          = 135
    case dash_720p          = 136
    case dash_1080p         = 137
    
    // all qualities that can be played on Apple TV
    public static let playable = [
        main_1080p, webm_1080p, dash_1080p,
        main_720p, webm_720p, dash_720p,
        flv_480p, webm_480p, dash_480p,
        main_360p, flv_360p, webm_360p, dash_360p
    ]
    
    public static let videoOnly = [dash_1080p, dash_720p, dash_480p, dash_360p]
}

enum YouTubeAudio: Int {
    // dash aac audio
    case aac_48kbps         = 139
    case aac_128kbps        = 140
    case aac_256kbps        = 141
    
    // dash webm audio
    case webm_128kbps       = 171
    case webm_256kbps       = 172
    
    public static let audioOnly = [
        aac_256kbps, webm_256kbps,
        aac_128kbps, webm_128kbps,
        aac_48kbps
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
