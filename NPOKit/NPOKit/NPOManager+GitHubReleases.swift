//
//  NPOManager+GitHubTags.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 20/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import Alamofire

extension NPOManager {
    // https://api.github.com/repos/:user/:repo/releases
    public func getGitHubReleases(forUsername username: String, andRepositoryName repository: String, withCompletion completed: @escaping (_ releases: [GitHubRelease]?, _ error: NPOError?) -> Void = { releases, error in }) {
        let transport = NPOManager.sharedInstance.transport
        let url = "https://api.github.com/repos/\(username)/\(repository)/releases"
        _ = self.fetchModels(ofType: GitHubRelease.self, fromURL: url, withKeyPath: nil, withCompletion: completed)
    }
}
