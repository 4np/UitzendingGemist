//
//  NPOManager+Episodes.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire

extension NPOManager {
    // MARK: Trending Episodes
    
    // http://apps-api.uitzendinggemist.nl/episodes/trending.json
    public func getTrendingEpisodes(withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "episodes/trending.json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // MARK: Popular Episodes
    
    // http://apps-api.uitzendinggemist.nl/episodes/popular.json
    public func getPopularEpisodes(withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "episodes/popular.json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // MARK: Recent Episodes
    
    // http://apps-api.uitzendinggemist.nl/broadcasts/recent.json
    public func getRecentEpisodes(withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "broadcasts/recent.json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withKeyPath: "episode", withCompletion: completed)
    }
    
    // MARK: Details

    // http://apps-api.uitzendinggemist.nl/episodes/POW_02989402.json
    public func getDetails(forEpisode episode: NPOEpisode, withCompletion completed: @escaping (_ episode: NPOEpisode?, _ error: NPOError?) -> () = { episode, error in }) -> Request? {
        guard let mid = episode.mid else {
            completed(nil, .noMIDError)
            return nil
        }
        
        let path = "episodes/\(mid).json"
        return self.fetchModel(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // MARK: By Genre
    
    // http://apps-api.uitzendinggemist.nl/episodes/genre/Documentaire.json
    public func getEpisodes(byGenre genre: NPOGenre, withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "episodes/genre/\(genre.rawValue).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // MARK: By broadcaster

    // http://apps-api.uitzendinggemist.nl/episodes/broadcaster/NOS.json
    public func getEpisodes(byBroadcaster broadcaster: NPOBroadcaster, withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let path = "episodes/broadcaster/\(broadcaster.rawValue).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // MARK: Searching
    
    // http://apps-api.uitzendinggemist.nl/episodes/search/reizen.json
    public func getEpisodes(bySearchTerm term: String, withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        let path = "episodes/search/\(encodedTerm).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // MARK: By Date

    // http://apps-api.uitzendinggemist.nl/broadcasts/2016-07-15.json
    public func getEpisodes(forDate date: Date, filterReruns filter: Bool, withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)
        
        // fetch episodes
        let path = "broadcasts/\(formattedDate).json"
        return self.fetchModels(ofType: NPOBroadcast.self, fromPath: path) { broadcasts, error in
            guard let broadcasts = broadcasts else {
                completed(nil, error)
                return
            }
        
            var mids = [String]()
            var episodes = [NPOEpisode]()
            
            // sort broadcasts in reverse order (e.g. old -> new)
            let sortedBroadcasts = broadcasts.sorted {
                guard let firstDate = $0.starts, let secondDate = $1.starts else {
                    return false
                }
                
                return firstDate.lies(before: secondDate)
            }
            
            for broadcast in sortedBroadcasts {
                guard let episode = broadcast.episode, let mid = episode.mid, let startsAt = broadcast.starts else {
                    continue
                }
                
                if !filter || !mids.contains(mid) {
                    mids.append(mid)
                    
                    // As the broadcast date of an episode might be different of the
                    // broadcast date of a 'broadcast' (even for broadcasts that are
                    // not marked as being a rerun) here we update the broadcast date
                    // for the episode to match that of the actual broadcast.
                    episode.broadcasted = startsAt
                    episodes.append(episode)
                }
            }
            
            completed(episodes.reversed(), error)
        }
    }
    
    // MARK: By Program
    
    // http://apps-api.uitzendinggemist.nl/episodes/series/POMS_S_VPRO_472240/latest.json
    public func getLatestEpisode(forProgram program: NPOProgram, withCompletion completed: @escaping (_ episode: NPOEpisode?, _ error: NPOError?) -> () = { episode, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(nil, .noMIDError)
            return nil
        }
        
        let path = "episodes/series/\(mid)/latest.json"
        return self.fetchModel(ofType: NPOEpisode.self, fromPath: path, withCompletion: completed)
    }
    
    // http://apps-api.uitzendinggemist.nl/series/POMS_S_VPRO_472240.json
    public func getEpisodes(forProgram program: NPOProgram, withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(nil, .noMIDError)
            return nil
        }
        
        let path = "series/\(mid).json"
        return self.fetchModels(ofType: NPOEpisode.self, fromPath: path, withKeyPath: "episodes", withCompletion: completed)
    }
    
    // http://apps-api.uitzendinggemist.nl/series/POMS_S_VPRO_472240.json
    public func getNextEpisode(forProgram program: NPOProgram, withCompletion completed: @escaping (_ episode: NPOEpisode?, _ error: NPOError?) -> () = { episode, error in }) -> Request? {
        guard let mid = program.mid else {
            completed(nil, .noMIDError)
            return nil
        }
        
        let path = "series/\(mid).json"
        return self.fetchModel(ofType: NPOEpisode.self, fromPath: path, withKeyPath: "next_episode", withCompletion: completed)
    }
    
    // MARK: By Favorite Programs
    
    public func getRecentEpisodesForFavoritePrograms(withCompletion completed: @escaping (_ episodes: [NPOEpisode]?, _ error: NPOError?) -> () = { episodes, error in }) {
        // get favorite programs
        self.getDetailedFavoritePrograms() { programs, errors in
            guard let programs = programs else {
                completed(nil, .noEpisodeError)
                return
            }
            
            var episodes = [NPOEpisode]()
            
            for program in programs {
                if let programEpisodes = program.episodes, let oldestUnwatchedEpisode = programEpisodes.filter({ $0.watched != .fully }).sorted(by: {
                    guard let firstDate = $0.broadcasted, let secondDate = $1.broadcasted else {
                        return false
                    }
                    
                    return firstDate.lies(before: secondDate)
                }).first {
                    episodes.append(oldestUnwatchedEpisode)
                }
            }
            
            completed(episodes, nil)
        }
    }
}
