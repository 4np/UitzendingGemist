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

public class NPOEpisode: NPORestrictedMedia {
    // Episode specific properties
    // http://apps-api.uitzendinggemist.nl/episodes/AT_2049573.json
    // http://apps-api.uitzendinggemist.nl/tips.json
    // http://apps-api.uitzendinggemist.nl/episodes/popular.json
    
    public internal(set) var duration: Int = 0
    public internal(set) var advisories = [String]()
    public internal(set) var broadcasted: NSDate?
    public internal(set) var broadcastChannel: String?
    public internal(set) var program: NPOProgram?
    
    public var broadcastedDisplayValue: String {
        guard let broadcasted = self.broadcasted else {
            return NPOConstants.unknownText
        }
        
        return broadcasted.daysAgoDisplayValue
    }
    
    //MARK: Lifecycle
    
    required convenience public init?(_ map: Map) {
        self.init()
    }
    
    //MARK: Mapping
    
    public override func mapping(map: Map) {
        super.mapping(map)
        
        duration <- map["duration"]
        advisories <- map["advisories"]
        broadcasted <- (map["broadcasted_at"], DateTransform())
        broadcastChannel <- map["broadcasted_on"]
        program <- map["series"]
    }
    
    //MARK: Realm
    
    lazy internal var realmEpisode: RealmEpisode? = {
        do {
            let realm = try Realm()
            
            // get first instance by mid
            guard let mid = self.mid, episode = realm.objects(RealmEpisode).filter("mid = '\(mid)'").first else {
                // create a new instance
                let episode = RealmEpisode()
                episode.mid = self.mid
                episode.name = self.name
                episode.info = self.description
                episode.program = self.program?.realmProgram
                episode.broadcasted = self.broadcasted
                episode.duration = self.duration
                episode.watchDuration = 0
                episode.watched = Watched.Unwatched.rawValue
                
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
    
    
    //MARK: Watched
    
    //swiftlint:disable force_unwrapping
    public var watched: Watched {
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
    
    //MARK: Watch duration
    
    private var updateProgramTimer: NSTimer?

    public var watchDuration: Int? {
        get {
            return self.realmEpisode?.watchDuration
        }
        set {
            do {
                let realm = try Realm()
                let newWatchDuration = newValue ?? 0
                
                try realm.write {
                    // check if user watched up to the last 2 minutes
                    if newWatchDuration > (duration - 120) {
                        // mark as watched
                        self.realmEpisode?.watchDuration = 0
                        self.realmEpisode?.watched = Watched.Fully.rawValue
                    } else if newWatchDuration < 60 {
                        self.realmEpisode?.watchDuration = newWatchDuration
                        self.realmEpisode?.watched = Watched.Unwatched.rawValue
                    } else {
                        self.realmEpisode?.watchDuration = newWatchDuration
                        self.realmEpisode?.watched = Watched.Partially.rawValue
                    }
                }
            } catch let error as NSError {
                DDLogError("Could not write episode to realm (\(error.localizedDescription))")
            }

            // update the program as well
            updateProgramTimer?.invalidate()
            updateProgramTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(updateProgram), userInfo: nil, repeats: false)
        }
    }

//    @objc private func delayedUpdateEpisode(timer: NSTimer) {
//        guard let duration = timer.userInfo?["duration"] as? Int else {
//            return
//        }
//        
//        DDLogDebug("delayedUpdateEpisode: \(duration)")
//        
//        // update realm
//        dispatch_async(dispatch_get_main_queue()) { [weak self] in
//            do {
//                let realm = try Realm()
//                
//                try realm.write {
//                    self?.realmEpisode?.watchDuration = duration
//                    
//                    // check if user watched up to the last 2 minutes
//                    if duration > (duration - 120) {
//                        // mark as watched
//                        self?.realmEpisode?.watched = true
//                    } else if duration < 60 {
//                        // mark as unwatched
//                        self?.realmEpisode?.watched = false
//                    }
//                    
//                    DDLogDebug("episode realm written...")
//                }
//            } catch let error as NSError {
//                DDLogError("Could not write episode to realm (\(error.localizedDescription))")
//            }
//
//            // update program
//            self?.program?.updateWatched()
//        }
//    }
    
    @objc private func updateProgram() {
        self.program?.updateWatched()
    }
    
    //MARK: Image fetching
    
    internal override func getImageURLs(withCompletion completed: (urls: [NSURL]) -> ()) -> Request? {
        var urls = [NSURL]()
        
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
        
        // got a program url?
        if let url = self.program?.imageURL {
            urls.append(url)
        }
    
        // done
        completed(urls: urls)
        
        return nil
    }
}
