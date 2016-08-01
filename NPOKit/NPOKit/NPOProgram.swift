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

public class NPOProgram: NPORestrictedMedia {
    // program specific properties
    // e.g. http://apps-api.uitzendinggemist.nl/episodes/AT_2049573.json
    internal var online: NSDate?
    internal var offline: NSDate?
    public private(set) var episodes: [NPOEpisode]?
    public private(set) var nextEpisode: NPOEpisode?
    
    public var firstLetter: String? {
        return self.getFirstLetter()
    }
    
    override public var available: Bool {
        get {
            let restrictionOkay = restriction?.available ?? true
            return !self.revoked && self.active && self.isOnline() && restrictionOkay
        }
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        online <- (map["expected_online_at"], DateTransform())
        offline <- (map["expected_offline_at"], DateTransform())
        episodes <- map["episodes"]
        nextEpisode <- map["next_episode"]
    }
    
    //MARK: Date checking
    
    internal func isOnline() -> Bool {
        return self.isOnline(atDate: NSDate())
    }
    
    internal func isOnline(atDate date: NSDate) -> Bool {
        guard let online = self.online, offline = self.offline else {
            return true
        }
        
        return (date.compare(online) == .OrderedDescending && date.compare(offline) == .OrderedAscending)
    }
    
    //MARK: Realm
    
    lazy internal var realmProgram: RealmProgram? = {
        do {
            let realm = try Realm()
            
            // get first instance by mid
            guard let mid = self.mid, program = realm.objects(RealmProgram).filter("mid = '\(mid)'").first else {
                // create a new instance
                let program = RealmProgram()
                program.mid = self.mid
                program.name = self.name
                program.firstLetter = self.firstLetter
                program.favorite = false
                program.watched = Watched.Unwatched.rawValue
                
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
    
    private func getFirstLetter() -> String? {
        guard let trimmedName = self.name?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else {
            return nil
        }
        
        let words = trimmedName.componentsSeparatedByString(" ")
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
            
            let letter = "\(char)".lowercaseString
            
            if let _ = Int(letter) {
                return "#"
            } else {
                return letter
            }
        }
        
        return nil
    }
    
    //MARK: Favoriting
    
    public var favorite: Bool {
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
    
    public func toggleFavorite() {
        favorite = !favorite
    }
    
    //MARK: Watched
    
    //swiftlint:disable force_unwrapping
    public var watched: Watched {
        get {
            let watchedValue = realmProgram?.watched ?? 0
            return Watched(rawValue: watchedValue)!
        }
    }
    //swiftlint:enable force_unwrapping
    
    internal func updateWatched() {
        getEpisodes() { [weak self] episodes in
            let episodeCount = episodes.count
            let watchedEpisodeCount = episodes.filter({ $0.watched == .Fully }).count
            let partiallyWatchedEpisodeCount = episodes.filter({ $0.watched == .Partially }).count
            
            let watched: Watched
                if watchedEpisodeCount == episodeCount {
                    watched = .Fully
                } else if partiallyWatchedEpisodeCount > 0 {
                    watched = .Partially
                } else {
                    watched = .Unwatched
            }
            
            // update realm
            dispatch_async(dispatch_get_main_queue()) {
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
    
    private func getEpisodes(withCompletion completed: (episodes: [NPOEpisode]) -> () = { episodes in }) {
        // check if we have episodes
        if let episodes = self.episodes where !episodes.isEmpty {
            completed(episodes: episodes)
            return
        }
        
        // fetch the episodes for this program
        NPOManager.sharedInstance.getEpisodes(forProgram: self) { episodes, error in
            guard let episodes = episodes else {
                DDLogError("Could not fetch episodes for program (\(error))")
                return
            }
            
            completed(episodes: episodes)
        }
    }
    
    //MARK: Image fetching
    
    //swiftlint:disable cyclomatic_complexity
    internal override func getImageURLs(withCompletion completed: (urls: [NSURL]) -> ()) -> Request? {
        var urls = [NSURL]()
        var stills = [NSURL]()
        
        // add program image
        if let url = self.imageURL {
            urls.append(url)
        }
        
        // add still image urls
        for still in self.stills ?? [] {
            if let url = still.imageURL {
                urls.append(url)
            }
        }
        
        // add fragment stills
        for fragment in self.fragments ?? [] {
            for still in fragment.stills ?? [] {
                if let url = still.imageURL {
                    urls.append(url)
                }
            }
        }
        
        // fetch episodes
        return NPOManager.sharedInstance.getEpisodes(forProgram: self) { episodes, error in
            guard let episodes = episodes else {
                completed(urls: urls)
                return
            }
            
            for episode in episodes {
                // add episode image url
                if let url = episode.imageURL {
                    urls.append(url)
                }
                
                // add still image urls
                for still in episode.stills ?? [] {
                    if let url = still.imageURL {
                        stills.append(url)
                    }
                }
            }
            
            // combine image and still urls
            urls.appendContentsOf(stills)
            
            completed(urls: urls)
        }
    }
    //swiftlint:enable cyclomatic_complexity
}
