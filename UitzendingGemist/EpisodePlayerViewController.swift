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
        
        DDLogDebug("episode stream (begin at \(seconds)s) url: \(url)")
        
        // when the player reached the end of the video, pause it
        player.actionAtItemEnd = .pause

        addObservers(player: player)
        
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
    
    // MARK: Observers
    
    private func addObservers(player: AVPlayer) {
        // observe any playback issues that may happen
        NotificationCenter.default.addObserver(self, selector: #selector(playbackHasStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackError(notification:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerFailedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        
        // observe when the player is done playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notifications
    
    @objc private func playerDidFinishPlaying(notification: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        
        dismiss(animated: true) {
            DDLogDebug("Finished playing episode, dismissed video player")
        }
    }

    @objc private func playerFailedToPlayToEndTime(notification: NSNotification) {
        DDLogDebug("Player failed to play to end time")
        removeObservers()
    }
    
    @objc private func playbackHasStalled(notification: NSNotification) {
        guard let playerItem = notification.object as? AVPlayerItem else {
            DDLogDebug("Playback has stalled...")
            return
        }
        
        DDLogDebug("Playback has stalled (buffer full: \(playerItem.isPlaybackBufferFull), buffer empty: \(playerItem.isPlaybackBufferEmpty), likely to keep up: \(playerItem.isPlaybackLikelyToKeepUp), is proxy: \(playerItem.isProxy()))")
    }
    
    @objc private func playbackError(notification: NSNotification) {
        guard let playerItem = notification.object as? AVPlayerItem, let error = playerItem.errorLog() else { return }
        
        DispatchQueue.main.async {
            DDLogDebug("Playback error: \(error) (\(error.events.count) events)")
            for event in error.events {
                DDLogDebug("Playback error event: \(event.errorComment) (domain: \(event.errorDomain), code: \(event.errorStatusCode))")
            }
        }
    }
}
