//
//  NPOManager+ExtraResources.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 18/11/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import XCDYouTubeKit
import GoogleAPIClientForREST
import AVKit
import CocoaLumberjack

public typealias NPOYouTubeVideo = GTLRYouTube_SearchResult

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

    internal func getProgramResources(withCompletion completed: @escaping (_ resources: [NPOProgramResource]?, _ error: NPOError?) -> () = { resources, error in }) {
        // check if we need to update (once a day)
        guard
            let cachedProgramResources = self.cachedProgramResources,
            let date = cachedProgramResourcesLastUpdated,
            let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day,
            days < 1
        else {
            let url = "https://raw.githubusercontent.com/4np/NPOKitResources/master/ProgramResources.json"
            let _ = self.fetchModels(ofType: NPOProgramResource.self, fromURL: url, withKeyPath: nil, withCompletion: { [weak self] resources, error in
                if let resources = resources {
                    // cache resources
                    self?.cachedProgramResources = resources
                    self?.cachedProgramResourcesLastUpdated = Date()
                }
                
                completed(resources, error)
            })
            return
        }
        
        // use cached resources
        completed(cachedProgramResources, nil)
    }
    
    internal func getResources(forProgram program: NPOProgram, withCompletion completed: @escaping (_ resource: NPOProgramResource?) -> () = { resource in }) {
        guard let mid = program.mid else {
            return
        }
        
        getProgramResources() { resources, error in
            guard let resource = resources?.filter({ $0.mid == mid }).first else {
                return
            }
            
            completed(resource)
        }
    }
    
    // MARK: Get Videos
    
    // https://www.googleapis.com/youtube/v3/search?key=...&channelId=UCdH_8mNJ9vzpHwMNwlz88Zw&part=snippet,id&order=date&maxResults=50
    final public func getYouTubeVideos(forProgram program: NPOProgram, withCompletion completed: @escaping (_ videos: [NPOYouTubeVideo]?, _ error: Error?) -> () = { videos, error in }) {
        guard let channel = program.extraResource?.youTubeChannel else {
            DDLogDebug("Trying to fetch YouTube channel for a program without extra resources")
            return
        }
        
        let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet,id")
        query.order = "date"
        query.maxResults = 50
        query.channelId = channel
        
        guard let youtubeService = NPOManager.youtubeService else {
            return completed(nil, nil)
        }
        
        // fetch videos for this channel
        youtubeService.executeQuery(query) { ticket, result, error in
            guard let response = result as? GTLRYouTube_SearchListResponse, let videos = response.items else {
                completed(nil, error)
                return
            }
            
            completed(videos, nil)
        }
    }
    
    // MARK: Get Player Item
    
    final public func getPlayerItem(youtubeVideoIdentifier videoIdentifier: String, withCompletion completed: @escaping (_ playerItem: AVPlayerItem?, _ error: NPOError?) -> () = { playerItem, error in }) {
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
    
    // MARK: Get Image
    
    final public func getImage(forYouTubeVideo video: NPOYouTubeVideo, ofSize size: CGSize, withCompletion completed: @escaping (_ image: UIImage?, _ error: NPOError?) -> () = { image, error in }) -> Request? {
        guard let thumbnailURL = video.snippet?.thumbnails?.high?.url else {
            return nil
        }
        
        let url = URL(string: thumbnailURL)
        
        return getImage(forURL: url, ofSize: size, withCompletion: completed)
    }
}
