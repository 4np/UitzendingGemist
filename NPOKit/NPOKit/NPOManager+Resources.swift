//
//  NPOManager+Resources.swift
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
}
