//
//  NPOManager.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 13/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RealmSwift
import CocoaLumberjack

public enum Watched: Int {
    case unwatched
    case partially
    case fully
}

public enum NPOError {
    case modelMappingError(String)//, JSON)
    case tokenError(String)
    case networkError(String)
    case noImageError
    case noMIDError
    case noEpisodeError
    case resourceError(String)
}

public enum NPOGenre: String {
    case amusement = "Amusement"
    case crime = "Misdaad"
    case cultural = "Kunst/Cultuur"
    case comedy = "Comedy"
    case documentary = "Documentaire"
    case drama = "Drama"
    case film = "Film"
    case health = "Gezondheid"
    case informative = "Informatief"
    case music = "Muziek"
    case nature = "Natuur"
    case news = "Nieuws/actualiteiten"
    case religious = "Religieus"
    case series = "Serie/soap"
    case sport = "Sport"
    case youth = "Jeugd"
    
    static let all = [amusement, crime, cultural, comedy, documentary, drama, film, health, informative, music, nature, news, religious, series, sport, youth]
}

public enum NPOBroadcaster: String {
    case vara = "VARA"
    case nos = "NOS"
    case kro = "KRO"
    case ncrv = "NCRV"
    case kroncrv = "KRO-NCRV"
    case avro = "AVRO"
    case tros = "TROS"
    case avrotros = "AVROTROS"
    case bnn = "BNN"
    case eo = "EO"
    case human = "HUMAN"
    case ikon = "IKON"
    case max = "MAX"
    case ntr = "NTR"
    case nps = "NPS"
    case ohm = "OHM"
    case vpro = "VPRO"
    case wnl = "WNL"
    case powned = "PowNed"
    case bos = "BOS"
    case zapp = "NPO Zapp"
    case zappelin = "NPO Zappelin"
    case joodseOmroep = "Joodse Omroep"
    
    static let all = [vara, nos, kro, ncrv, kroncrv, avro, tros, avrotros, bnn, eo, human, ikon, max, ntr, nps, ohm, vpro, wnl, powned, bos, joodseOmroep, zapp, zappelin]
}

open class NPOManager {
    open static let sharedInstance = NPOManager()
    fileprivate let infoDictionary = Bundle.main.infoDictionary
    
    // cache token
    internal var token: NPOToken?

    // see NPOManager+ExtraResources
    internal var cachedProgramResources: [NPOProgramResource]?
    internal var cachedProgramResourcesLastUpdated: Date?
    
    open internal(set) var geo: GEO?
    
    // MARK: Init
    
    init() {
        upgradeIfNeeded()
        
        // fetch geo information by ip
        getGeo { [weak self] geo, error in
            self?.geo = geo
            
            if let error = error {
                DDLogError("Could not fetch geo information (\(error))")
            }
        }
    }
    
    //swiftlint:disable force_unwrapping
    fileprivate func upgradeIfNeeded() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    DDLogDebug("Performing schema upgrade \(oldSchemaVersion) to 1")
                    
                    // migrate NPOProgram object
                    migration.enumerateObjects(ofType: RealmProgram.className()) { _, newObject in
                        newObject!["watched"] = Watched.unwatched.rawValue
                    }
                
                    // migrate NPOEpisode object
                    migration.enumerateObjects(ofType: RealmEpisode.className()) { oldObject, newObject in
                        if let watched = oldObject!["watched"] as? Bool, let watchDuration = oldObject!["watchDuration"] as? Int {
                            if watched {
                                newObject!["watched"] = Watched.fully.rawValue
                            } else if watchDuration > 59 {
                                newObject!["watched"] = Watched.partially.rawValue
                            } else {
                                newObject!["watched"] = Watched.unwatched.rawValue
                            }
                        } else {
                            newObject!["watched"] = Watched.unwatched.rawValue
                        }
                    }
                }
        })

        // Realm will automatically perform the migration and opening the Realm will succeed
        do {
            _ = try Realm()
        } catch let error as NSError {
            DDLogError("Realm schema upgrade error (\(error.localizedDescription))")
        }
    }
    //swiftlint:enable force_unwrapping
    
    // MARK: Get url
    
    internal func getURL(forPath path: String) -> String {
        return "\(transport)://apps-api.uitzendinggemist.nl/\(path)"
    }
    
    // MARK: Request headers
    
    internal func getHeaders() -> [String:String] {
        return [
            //"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7",
            "DNT": "1",
            "Accept-Encoding": "gzip, deflate, sdch",
            "Accept": "*/*",
            "X-UitzendingGemist-Version": (infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"),
            "X-UitzendingGemist-Source": "https://github.com/4np/UitzendingGemist/tree/master/NPOKit",
            "X-UitzendingGemist-Platform": (infoDictionary?["DTSDKName"] as? String ?? "unknown"),
            "X-UitzendingGemist-PlatformVersion": (infoDictionary?["DTPlatformVersion"] as? String ?? "unknown")
        ]
    }

    // MARK: Image caching
    
    lazy internal var imageCache: AutoPurgingImageCache = {
        let imageCache = AutoPurgingImageCache(
            memoryCapacity: 500 * 1024 * 1024,
            preferredMemoryUsageAfterPurge: 120 * 1024 * 1024
        )
        //DDLogDebug("memory usage: \(imageCache.memoryUsage), capacity: \(imageCache.memoryCapacity), prefered after purge: \(imageCache.preferredMemoryUsageAfterPurge)")
        return imageCache
    }()
    
    // MARK: Episode stream quality order of preference
    
    lazy internal var preferredEpisodeQualityOrder: [NPOStreamType] = {
        var streamTypes = [NPOStreamType]()
        
        defer {
            DDLogDebug("Episode stream quality order of preference: \(streamTypes.map { $0.rawValue })")
        }
        
        // try to fetch the preferred episode quality types
        guard let path = Bundle.main.path(forResource: "Settings", ofType: "plist"), let order = NSDictionary(contentsOfFile: path)?.object(forKey: "UGPreferedEpisodeQualityOrder") as? String else {
            // use the default preferred order
            streamTypes = NPOStreamType.preferredOrder
            return streamTypes
        }
        
        for type in order.components(separatedBy: ",") {
            guard let streamType = NPOStreamType(rawValue: type.trimmed) else { continue }
            streamTypes.append(streamType)
        }
        
        return streamTypes
    }()
    
    // MARK: Return the transport to use (http vs https)
    
    internal var transport: String {
        let secureTransportIsEnabled = UserDefaults.standard.bool(forKey: "UGSecureTransportEnabled")
        return secureTransportIsEnabled ? "https" : "http"
    }
}
