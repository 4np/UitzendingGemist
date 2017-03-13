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

extension AVPlayerStatus {
    var description: String {
        switch self {
        case .failed:
            return "Failed"
        case .readyToPlay:
            return "ReadyToPlay"
        case .unknown:
            return "Unknown"
        }
    }
}

extension AVPlayerTimeControlStatus {
    var description: String {
        switch self {
        case .paused:
            return "Paused"
        case .playing:
            return "Playing"
        case .waitingToPlayAtSpecifiedRate:
            return "WaitingToPlayAtSpecifiedRate"
        }
    }
}

class EpisodePlayerViewController: AVPlayerViewController {
    // keep track of the number of seconds played
    private var seconds = 0
    private var episode: NPOEpisode?
    
    // MARK: Lifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        super.viewWillDisappear(animated)
    }
    
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
    
    private var observerContext = 0
    
    func play(episode: NPOEpisode, withVideoStream url: URL, beginAt seconds: Int) {
        let player = AVPlayer(url: url)
        
        //DDLogDebug("Episode stream (begin at \(seconds)s) url: \(url)")
        
        // when the player reached the end of the video, pause it
        player.actionAtItemEnd = .pause
        
        // handle stalling
        player.automaticallyWaitsToMinimizeStalling = true

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
        
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: &observerContext)
        
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
        self.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: &observerContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &observerContext, let item = player?.currentItem else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        guard let old = change?[.oldKey] as? Int, let new = change?[.newKey] as? Int, new != old, let timeControlStatus = AVPlayerTimeControlStatus(rawValue: new) else { return }

        switch timeControlStatus {
            case .paused:
                DDLogDebug("Player is now paused")
            case .playing:
                DDLogDebug("Player is now playing")
                if !item.canPlayReverse || !item.canPlaySlowReverse || !item.canPlayFastReverse || !item.canPlaySlowForward || !item.canPlayFastForward {
                    DDLogDebug("Can play reverse: \(item.canPlayReverse) (slow: \(item.canPlaySlowReverse), fast: \(item.canPlayFastReverse)) and forward: slow: \(item.canPlaySlowForward), fast: \(item.canPlayFastForward)")
                }
            case .waitingToPlayAtSpecifiedRate:
                DDLogDebug("Player is now waiting to play at the specified rate")
        }
    }
    
    // MARK: Notifications
    
    @objc private func playerDidFinishPlaying(notification: NSNotification) {
        removeObservers()
        
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
            DDLogDebug("Playback has stalled")
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
