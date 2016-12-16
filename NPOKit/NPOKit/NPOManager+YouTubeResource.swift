//
//  NPOManager+YouTubeResource.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 20/11/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import XCDYouTubeKit
import GoogleAPIClientForREST
import AVKit
import CocoaLumberjack

public struct NPOYouTubeVideo {
    public internal(set) var title: String?
    public internal(set) var published: Date?
    internal(set) var videoIdentifier: String?
    internal(set) var imageURL: String?
}

extension NPOManager {
    fileprivate static var youtubeService: GTLRYouTubeService? = {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let key = NSDictionary(contentsOfFile: path)?.object(forKey: "ytak") as? String
            else {
                return nil
        }
        
        let service = GTLRYouTubeService.init()
        service.apiKey = key
        service.shouldFetchNextPages = true
        return service
    }()

    // MARK: Networking
    
    // https://www.googleapis.com/youtube/v3/search?key=...&channelId=UCdH_8mNJ9vzpHwMNwlz88Zw&part=snippet,id&order=date&maxResults=50
    final public func getYouTubeVideos(forProgram program: NPOProgram, withCompletion completed: @escaping (_ videos: [NPOYouTubeVideo]?, _ error: Error?) -> () = { videos, error in }) {
        guard program.hasYouTubeResource else {
            DDLogDebug("Trying to fetch YouTube resources for a program without extra resources")
            return
        }
        
        if let playlist = program.extraResource?.youTubePlaylist {
            getYouTubeVideos(forYouTubePlaylist: playlist, withCompletion: completed)
        } else if let channel = program.extraResource?.youTubeChannel {
            getYouTubeVideos(forYouTubeChannel: channel, withCompletion: completed)
        }
    }
    
    fileprivate func getYouTubeVideos(forYouTubeChannel channel: String, withCompletion completed: @escaping (_ videos: [NPOYouTubeVideo]?, _ error: Error?) -> () = { videos, error in }) {
        DDLogDebug("getYouTubeVideos forYouTubeChannel \(channel)")
        
        let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet,id")
        query.order = "date"
        query.maxResults = 50
        query.channelId = channel
        
        guard let youtubeService = NPOManager.youtubeService else {
            return completed(nil, nil)
        }
        
        // fetch videos for this channel
        youtubeService.executeQuery(query) { ticket, result, error in
            //DDLogDebug("ticket: \(ticket)")
            //DDLogDebug("result: \(result)")

            guard let response = result as? GTLRYouTube_SearchListResponse, let videos = response.items else {
                completed(nil, error)
                return
            }
            
            var youTubeVideos = [NPOYouTubeVideo]()
            for video in videos {
                guard let identifier = video.identifier?.videoId else {
                    continue
                }
                
                let youTubeVideo = NPOYouTubeVideo(
                    title: video.snippet?.title,
                    published: video.snippet?.publishedAt?.date,
                    videoIdentifier: identifier,
                    imageURL: video.snippet?.thumbnails?.high?.url)
                youTubeVideos.append(youTubeVideo)
            }
            
            completed(youTubeVideos, nil)
        }
    }
    
    fileprivate func getYouTubeVideos(forYouTubePlaylist playlist: String, withCompletion completed: @escaping (_ videos: [NPOYouTubeVideo]?, _ error: Error?) -> () = { videos, error in }) {
        DDLogDebug("getYouTubeVideos forYouTubePlaylist \(playlist)")
        
        let query = GTLRYouTubeQuery_PlaylistItemsList.query(withPart: "snippet,id")
        query.maxResults = 50
        query.playlistId = playlist
        
        guard let youtubeService = NPOManager.youtubeService else {
            return completed(nil, nil)
        }
        
        // fetch videos for this channel
        youtubeService.executeQuery(query) { ticket, result, error in
            //DDLogDebug("ticket: \(ticket)")
            //DDLogDebug("result: \(result)")
            
            guard let response = result as? GTLRYouTube_PlaylistItemListResponse, let videos = response.items else {
                completed(nil, error)
                return
            }
            
            var youTubeVideos = [NPOYouTubeVideo]()
            for video in videos {
                guard let identifier = video.snippet?.resourceId?.videoId else {
                    continue
                }
                
                let youTubeVideo = NPOYouTubeVideo(
                    title: video.snippet?.title,
                    published: video.snippet?.publishedAt?.date,
                    videoIdentifier: identifier,
                    imageURL: video.snippet?.thumbnails?.high?.url)
                youTubeVideos.append(youTubeVideo)
            }
            
            completed(youTubeVideos, nil)
        }
    }
    
    // MARK: Player Item
    
    final public func getPlayerItem(youTubeVideo video: NPOYouTubeVideo, withCompletion completed: @escaping (_ playerItem: AVPlayerItem?, _ error: NPOError?) -> () = { playerItem, error in }) {
        guard let videoIdentifier = video.videoIdentifier else {
            return
        }
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { video, error in
            // make sure we have a video
            guard let playerItem = video?.getPlayerItem() else {
                let details = error?.localizedDescription ?? "no suitable video formats"
                completed(nil, NPOError.resourceError("Could not play YouTube video \(details)"))
                return
            }
            
            completed(playerItem, nil)
        }
    }
    
    // MARK: Image
    
    final public func getImage(forYouTubeVideo video: NPOYouTubeVideo, ofSize size: CGSize, withCompletion completed: @escaping (_ image: UIImage?, _ error: NPOError?) -> () = { image, error in }) -> Request? {
        guard let urlString = video.imageURL else {
            return nil
        }
        
        let url = URL(string: urlString)
        return getImage(forURL: url, ofSize: size, withCompletion: completed)
    }
}
