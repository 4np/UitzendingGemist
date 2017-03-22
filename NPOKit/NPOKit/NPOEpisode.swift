//
//  NPOEpisode.swift
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

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

open class NPOEpisode: NPORestrictedMedia {
    // Episode specific properties
    // http://apps-api.uitzendinggemist.nl/episodes/AT_2049573.json
    // http://apps-api.uitzendinggemist.nl/tips.json
    // http://apps-api.uitzendinggemist.nl/episodes/popular.json
    
    open internal(set) var duration: Int = 0
    open internal(set) var advisories = [String]()
    open internal(set) var broadcasted: Date?
    open internal(set) var broadcastChannel: String?
    open internal(set) var program: NPOProgram?
    
    open var broadcastedDisplayValue: String {
        guard let broadcasted = self.broadcasted else {
            return NPOConstants.unknownText
        }
        
        return broadcasted.daysAgoDisplayValue
    }
    
    open var subtitleURL: URL? {
        guard let mid = mid else { return nil }
        return URL(string: "https://tt888.omroep.nl/tt888/\(mid)")
    }
    
    // MARK: Lifecycle
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: Mapping
    
    open override func mapping(map: Map) {
        super.mapping(map: map)
        
        duration <- map["duration"]
        advisories <- map["advisories"]
        broadcasted <- (map["broadcasted_at"], DateTransform())
        broadcastChannel <- map["broadcasted_on"]
        program <- map["series"]
    }
    
    // MARK: Realm
    
    lazy internal var realmEpisode: RealmEpisode? = {
        do {
            let realm = try Realm()
            
            // get first instance by mid
            guard let mid = self.mid, let episode = realm.objects(RealmEpisode.self).filter("mid = '\(mid)'").first else {
                // create a new instance
                let episode = RealmEpisode()
                episode.mid = self.mid
                episode.name = self.name
                episode.info = self.description
                episode.program = self.program?.realmProgram
                episode.broadcasted = self.broadcasted
                episode.duration = self.duration
                episode.watchDuration = 0
                episode.watched = Watched.unwatched.rawValue
                
                // add episode to realm
                try realm.write {
                    realm.add(episode)
                }
                
                return episode
            }
            
            return episode
        } catch let error as NSError {
            DDLogError("Could not fetch episode from realm (\(error.localizedDescription))")
            return nil
        }
    }()
    
    // MARK: Watched
    
    //swiftlint:disable force_unwrapping
    open var watched: Watched {
        get {
            return Watched(rawValue: self.realmEpisode?.watched ?? 0)!
        }
        set {
            do {
                let realm = try Realm()
                
                try realm.write {
                    self.realmEpisode?.watched = newValue.rawValue
                }
            } catch let error as NSError {
                DDLogError("Could not write episode to realm (\(error.localizedDescription))")
            }
        }
    }
    //swiftlint:enable force_unwrapping
    
    // MARK: Watch duration
    
    fileprivate var updateProgramTimer: Timer?

    open var watchDuration: Int {
        get {
            return self.realmEpisode?.watchDuration ?? 0
        }
        set {
            do {
                let realm = try Realm()
                let newWatchDuration = newValue 
                
                try realm.write {
                    // check if user watched up to the last 2 minutes
                    if newWatchDuration > (duration - 120) {
                        // mark as watched
                        self.realmEpisode?.watchDuration = 0
                        self.realmEpisode?.watched = Watched.fully.rawValue
                    } else if newWatchDuration < 60 {
                        self.realmEpisode?.watchDuration = newWatchDuration
                        self.realmEpisode?.watched = Watched.unwatched.rawValue
                    } else {
                        self.realmEpisode?.watchDuration = newWatchDuration
                        self.realmEpisode?.watched = Watched.partially.rawValue
                    }
                }
            } catch let error as NSError {
                DDLogError("Could not write episode to realm (\(error.localizedDescription))")
            }

            // update the program as well
            updateProgramTimer?.invalidate()
            updateProgramTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateProgram), userInfo: nil, repeats: false)
        }
    }
    
    @objc fileprivate func updateProgram() {
        self.program?.updateWatched()
    }
    
    open func toggleWatched() {
        if watched == .partially || watched == .unwatched {
            watched = .fully
        } else if watchDuration > 59 {
            watched = .partially
        } else {
            watched = .unwatched
        }
    }
    
    // MARK: Image fetching
    
    internal override func getImageURLs(withCompletion completed: @escaping (_ urls: [URL]) -> Void = { urls in }) -> Request? {
        var urls = [URL]()
        
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
        
        // got a program url?
        if let url = self.program?.imageURL {
            urls.append(url as URL)
        }
    
        // done
        completed(urls)
        
        return nil
    }
}
