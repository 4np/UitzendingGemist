//
//  NPOProgram.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 14/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RealmSwift
import CocoaLumberjack

open class NPOProgram: NPORestrictedMedia {
    // program specific properties
    // e.g. http://apps-api.uitzendinggemist.nl/episodes/AT_2049573.json
    internal var online: Date?
    internal var offline: Date?
    open fileprivate(set) var episodes: [NPOEpisode]?
    open fileprivate(set) var nextEpisode: NPOEpisode?
    
    open var firstLetter: String? {
        return self.getFirstLetter()
    }
    
    override open var available: Bool {
        get {
            let restrictionOkay = restriction?.available ?? true
            return !self.revoked && self.active && self.isOnline() && restrictionOkay
        }
    }
    
    open var numberOfWatchedEpisodes: Int {
        return episodes?.filter({ $0.watched == .fully }).count ?? 0
    }
    
    //MARK: Lifecycle
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    //MARK: Mapping
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        online <- (map["expected_online_at"], DateTransform())
        offline <- (map["expected_offline_at"], DateTransform())
        episodes <- map["episodes"]
        nextEpisode <- map["next_episode"]
    }
    
    //MARK: Date checking
    
    internal func isOnline() -> Bool {
        return self.isOnline(atDate: Date())
    }
    
    internal func isOnline(atDate date: Date) -> Bool {
        guard let online = self.online, let offline = self.offline else {
            return true
        }
        
        return (date.compare(online) == .orderedDescending && date.compare(offline) == .orderedAscending)
    }
    
    //MARK: Realm
    
    lazy internal var realmProgram: RealmProgram? = {
        do {
            let realm = try Realm()
            
            // get first instance by mid
            guard let mid = self.mid, let program = realm.objects(RealmProgram.self).filter("mid = '\(mid)'").first else {
                // create a new instance
                let program = RealmProgram()
                program.mid = self.mid
                program.name = self.name
                program.firstLetter = self.firstLetter
                program.favorite = false
                program.watched = Watched.unwatched.rawValue
                
                // add program to realm
                try realm.write {
                    realm.add(program)
                }
                
                return program
            }
            
            return program
        } catch let error as NSError {
            DDLogError("Could not fetch program from realm (\(error.localizedDescription))")
            return nil
        }
    }()
    
    //MARK: Get first letter
    
    fileprivate func getFirstLetter() -> String? {
        guard let trimmedName = self.name?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return nil
        }
        
        let words = trimmedName.components(separatedBy: " ")
        let wordMapper = [
            "'t"    : "het",
            "t"     : "het"
        ]
        
        for word in words {
            var useWord = word
            
            // check if we need to map this word to something else
            if let mappedWord = wordMapper[word] {
                useWord = mappedWord
            }
            
            guard let char = useWord.characters.first else {
                continue
            }
            
            let letter = "\(char)".lowercased()
            
            if let _ = Int(letter) {
                return "#"
            } else {
                return letter
            }
        }
        
        return nil
    }
    
    //MARK: Favoriting
    
    open var favorite: Bool {
        get {
            return self.realmProgram?.favorite ?? false
        }
        set {
            do {
                let realm = try Realm()
                try realm.write {
                    self.realmProgram?.favorite = newValue
                }
            } catch let error as NSError {
                DDLogError("Could not write program to realm (\(error.localizedDescription))")
            }
        }
    }
    
    open func toggleFavorite() {
        favorite = !favorite
    }
    
    //MARK: Watched
    
    //swiftlint:disable force_unwrapping
    open var watched: Watched {
        get {
            let watchedValue = realmProgram?.watched ?? 0
            return Watched(rawValue: watchedValue)!
        }
    }
    //swiftlint:enable force_unwrapping
    
    internal func updateWatched() {
        getEpisodes() { [weak self] episodes in
            let episodeCount = episodes.count
            let watchedEpisodeCount = episodes.filter({ $0.watched == .fully }).count
            let partiallyWatchedEpisodeCount = episodes.filter({ $0.watched == .partially }).count
            
            let watched: Watched
                if watchedEpisodeCount == episodeCount {
                    watched = .fully
                } else if partiallyWatchedEpisodeCount > 0 {
                    watched = .partially
                } else {
                    watched = .unwatched
            }
            
            // update realm
            DispatchQueue.main.async {
                do {
                    let realm = try Realm()
                    try realm.write {
                        DDLogDebug("updating program... watched: \(watched.rawValue)")
                        self?.realmProgram?.watched = watched.rawValue
                    }
                } catch let error as NSError {
                    DDLogError("Could not write program to realm (\(error.localizedDescription))")
                }
            }
        }
    }
    
    fileprivate func getEpisodes(withCompletion completed: @escaping (_ episodes: [NPOEpisode]) -> () = { episodes in }) {
        // check if we have episodes
        if let episodes = self.episodes , !episodes.isEmpty {
            completed(episodes)
            return
        }
        
        // fetch the episodes for this program
        NPOManager.sharedInstance.getEpisodes(forProgram: self) { episodes, error in
            guard let episodes = episodes else {
                DDLogError("Could not fetch episodes for program (\(error))")
                return
            }
            
            completed(episodes)
        }
    }
    
    //MARK: Image fetching
    
    //swiftlint:disable cyclomatic_complexity
    internal override func getImageURLs(withCompletion completed: @escaping (_ urls: [URL]) -> () = { urls in }) -> Request? {
        var urls = [URL]()
        var stills = [URL]()
        
        // add program image
        if let url = self.imageURL {
            urls.append(url as URL)
        }
        
        // add still image urls
        for still in self.stills ?? [] {
            if let url = still.imageURL {
                urls.append(url as URL)
            }
        }
        
        // add fragment stills
        for fragment in self.fragments ?? [] {
            for still in fragment.stills {
                if let url = still.imageURL {
                    urls.append(url as URL)
                }
            }
        }
        
        // fetch episodes
        return NPOManager.sharedInstance.getEpisodes(forProgram: self) { episodes, error in
            guard let episodes = episodes else {
                completed(urls)
                return
            }
            
            for episode in episodes {
                // add episode image url
                if let url = episode.imageURL {
                    urls.append(url as URL)
                }
                
                // add still image urls
                for still in episode.stills ?? [] {
                    if let url = still.imageURL {
                        stills.append(url as URL)
                    }
                }
            }
            
            // combine image and still urls
            urls.append(contentsOf: stills)
            
            completed(urls)
        }
    }
    //swiftlint:enable cyclomatic_complexity
}
