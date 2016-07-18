//
//  NPOManager+Episodes.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Alamofire

extension NPOManager {
    
    //MARK: Popular Episodes
    
    // http://apps-api.uitzendinggemist.nl/episodes/popular.json
    public func getPopularEpisodes(withCompletion completed: (episodes: [NPOEpisode]?, error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "episodes/popular.json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    //MARK: Recent Episodes
    
    // http://apps-api.uitzendinggemist.nl/broadcasts/recent.json
    public func getRecentEpisodes(withCompletion completed: (episodes: [NPOEpisode]?, error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "broadcasts/recent.json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withKeyPath: "episode", withCompletion: completed)
    }
    
    //MARK: Details

    // http://apps-api.uitzendinggemist.nl/episodes/POW_02989402.json
    public func getDetails(forEpisode episode: NPOEpisode, withCompletion completed: (episode: NPOEpisode?, error: NPOError?) -> () = { episode, error in }) -> Request? {
        guard let mid = episode.mid else {
            completed(episode: nil, error: .NoMIDError)
            return nil
        }
        
        let path = "episodes/\(mid).json"
        return self.fetchModel(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    //MARK: By Genre
    
    // http://apps-api.uitzendinggemist.nl/episodes/genre/Documentaire.json
    public func getEpisodes(byGenre genre: NPOGenre, withCompletion completed: (episodes: [NPOEpisode]?, error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "episodes/genre/\(genre.rawValue).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    //MARK: By broadcaster

    // http://apps-api.uitzendinggemist.nl/episodes/broadcaster/NOS.json
    public func getEpisodes(byBroadcaster broadcaster: NPOBroadcaster, withCompletion completed: (episodes: [NPOEpisode]?, error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "episodes/broadcaster/\(broadcaster.rawValue).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    //MARK: Searching
    
    // http://apps-api.uitzendinggemist.nl/episodes/search/reizen.json
    public func getEpisodes(bySearchTerm term: String, withCompletion completed: (episodes: [NPOEpisode]?, error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let encodedTerm = term.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())
        let path = "episodes/search/\(encodedTerm).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    //MARK: By Date

    // http://apps-api.uitzendinggemist.nl/broadcasts/2016-07-15.json
    public func getEpisodes(forDate date: NSDate, withCompletion completed: (episodes: [NPOEpisode]?, error: NPOError?) -> () = { episodes, error in }) -> Request? {
        // format date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.stringFromDate(date)
        
        // fetch episodes
        let path = "broadcasts/\(formattedDate).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withKeyPath: "episode", withCompletion: completed)
    }
    
    //MARK: By Program
    
    // http://apps-api.uitzendinggemist.nl/episodes/series/POMS_S_VPRO_472240/latest.json
    public func getLatestEpisode(forProgram program: NPOProgram, withCompletion completed: (episode: NPOEpisode?, error: NPOError?) -> () = { episode, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(episode: nil, error: .NoMIDError)
            return nil
        }
        
        let path = "episodes/series/\(mid)/latest.json"
        return self.fetchModel(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // http://apps-api.uitzendinggemist.nl/series/POMS_S_VPRO_472240.json
    public func getEpisodes(forProgram program: NPOProgram, withCompletion completed: (episodes: [NPOEpisode]?, error: NPOError?) -> () = { episodes, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(episodes: nil, error: .NoMIDError)
            return nil
        }
        
        let path = "series/\(mid).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withKeyPath: "episodes", withCompletion: completed)
    }
    
    // http://apps-api.uitzendinggemist.nl/series/POMS_S_VPRO_472240.json
    public func getNextEpisode(forProgram program: NPOProgram, withCompletion completed: (episode: NPOEpisode?, error: NPOError?) -> () = { episode, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(episode: nil, error: .NoMIDError)
            return nil
        }
        
        let path = "series/\(mid).json"
        return self.fetchModel(ofType: NPOEpisode.self, fromPath: path, withKeyPath: "next_episode", withCompletion: completed)
    }
}
