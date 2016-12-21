//
//  EpisodePlayerViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 21/12/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import NPOKit
import CocoaLumberjack

class EpisodePlayerViewController: AVPlayerViewController {
    // keep track of the number of seconds played
    private var seconds = 0
    private var episode: NPOEpisode?
    
    // MARK: Lifecycle
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let episode = self.episode else {
            return
        }
        
        episode.watchDuration = seconds
        
        // nullify objects
        self.seconds = 0
        self.episode = nil
    }
    
    // MARK: Playing
    
    func play(episode: NPOEpisode, withVideoStream url: URL, beginAt seconds: Int) {
        let player = AVPlayer(url: url)
        
        // when the player reached the end of the video, pause it
        player.actionAtItemEnd = .pause
        
        // observe when the player is done playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        // (re)set play data
        self.seconds = seconds
        
        // seek to start?
        if seconds > 0 {
            let seekTime = CMTimeMakeWithSeconds(Float64(seconds), 1)
            player.seek(to: seekTime, toleranceBefore: kCMTimePositiveInfinity, toleranceAfter: kCMTimeZero)
        }
        
        // observe player
        let interval = CMTimeMakeWithSeconds(1, 1) // 1 second
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            self?.seconds = Int(time.seconds)
        }

        // assign locally
        self.episode = episode
        self.player = player
        
        // start playing
        self.player?.play()
    }
    
    @objc private func playerDidFinishPlaying(notification: NSNotification) {
        dismiss(animated: true) {
            DDLogDebug("Finished playing episode, dismissed video player")
        }
    }
}
