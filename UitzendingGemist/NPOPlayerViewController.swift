//
//  NPOPlayerViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 22/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
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

protocol NPOPlayerViewControllerDelegate: class {
    func playerDidFinishPlayback(atSeconds seconds: Int)
}

// Apple says: Do not subclass AVPlayer​View​Controller. Overriding
// this class’s methods is unsupported and results in undefined behavior.
// However, this class does not override any methods, it only adds new
// behaviour but we need to keep this into mind.
class NPOPlayerViewController: AVPlayerViewController {
    weak var npoDelegate: NPOPlayerViewControllerDelegate?
    
    // keep track of the number of seconds played
    private var seconds = 0
    private var observerContext = 0
    
    private lazy var isDebuggingEnabled: Bool = {
        guard let path = Bundle.main.path(forResource: "Settings", ofType: "plist"), let key = NSDictionary(contentsOfFile: path)?.object(forKey: "UGEnablePlayerDebugging") as? String else {
            return false
        }
        
        return (key == "YES")
    }()
    
    private lazy var closedCaptioningEnabled: Bool = {
        return UserDefaults.standard.bool(forKey: UitzendingGemistConstants.closedCaptioningEnabledKey)
    }()
    
    // MARK: Lifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        npoDelegate?.playerDidFinishPlayback(atSeconds: seconds)
        seconds = 0
        super.viewWillDisappear(animated)
    }
    
    // MARK: Playing
    
    func play(videoStream videoURL: URL, externalMetadata: [String: Any?]?) {
        play(videoStream: videoURL, subtitles: nil, beginAt: 0, externalMetadata: externalMetadata)
    }
    
    func play(videoStream videoURL: URL, subtitles subtitleURL: URL?, beginAt seconds: Int, externalMetadata: [String: Any?]?) {
        let player = AVPlayer(url: videoURL)
        
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
        let interval = CMTimeMakeWithSeconds(0.5, 60) // half a second
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            self?.seconds = Int(time.seconds)
            self?.displaySubtitles(atTime: time)
        }

        if isDebuggingEnabled {
            DDLogDebug("Debugging episode video player is enabled")
            player.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: &observerContext)
        }
        
        // assign locally
        self.player = player
        
        // add metadata
        if let metadata = externalMetadata, let data = getAVMetaData(forDictionary: metadata) {
            self.player?.currentItem?.externalMetadata = data
        }

        // add subtitles (if we have any)
        load(subtitlesAtURL: subtitleURL)
        
        // start playing
        self.player?.play()
    }
    
    // MARK: Video Metadata
    
    private func getAVMetaData(forDictionary dictionary: [String: Any?]) -> [AVMetadataItem]? {
        var metadata = [AVMetadataItem]()
        
        for (key, value) in dictionary {
            let metadataItem = AVMutableMetadataItem()
            metadataItem.locale = NSLocale.current
            metadataItem.key = key as (NSCopying & NSObjectProtocol)?
            metadataItem.keySpace = AVMetadataKeySpaceCommon
            
            switch key {
            case AVMetadataCommonKeyArtwork:
                guard let image = value as? UIImage else { continue }
                metadataItem.dataType = kCMMetadataBaseDataType_JPEG as String
                metadataItem.value = UIImageJPEGRepresentation(image, 1) as (NSCopying & NSObjectProtocol)?
            default:
                guard let text = value as? String else { continue }
                metadataItem.value = text as (NSCopying & NSObjectProtocol)?
            }
            
            metadata.append(metadataItem)
        }
        
        return metadata
    }
    
    // MARK: Observers
    
    private func addObservers(player: AVPlayer) {
        // observe any playback issues that may happen
        if isDebuggingEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(playbackHasStalled(notification:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: player.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playbackError(notification:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: player.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerFailedToPlayToEndTime(notification:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        }
        
        // observe when the player is done playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        if isDebuggingEnabled {
            self.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: &observerContext)
        }
    }
    
    //swiftlint:disable:next block_based_kvo
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
                DDLogDebug("Playback error event: \(String(describing: event.errorComment)) (domain: \(event.errorDomain), code: \(event.errorStatusCode))")
            }
        }
    }

    // MARK: Subtitles
    
    private var currentSubtitleNumber: Int?
    private var subtitles: [(number: Int, from: TimeInterval, to: TimeInterval, text: String)]?
    
    lazy var label: UILabel = {
        let bounds = self.view.bounds
        let frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: 400.0)
        let label = UILabel()// UILabel(frame: frame)
        
        // label configuration
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 45.0)
        
        // text positioning / wrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        // shadow
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        label.layer.shadowOpacity = 0.9
        label.layer.shadowRadius = 1.0
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale

        if let overlayView = self.contentOverlayView {
            // add label
            overlayView.addSubview(label)
            
            // layout anchors
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 100.0).isActive = true
            label.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 200.0).isActive = true
            label.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -200.0).isActive = true
            label.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -50.0).isActive = true
        }
        
        return label
    }()

    private func load(subtitlesAtURL subtitleURL: URL?) {
        currentSubtitleNumber = nil
        
        guard let url = subtitleURL else { return }
        
        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            self.subtitles = parse(subtitleContent: contents)
        } catch let error {
            DDLogError("Could not load subtitles (\(error.localizedDescription)")
        }
    }
    
    private func parse(subtitleContent content: String) -> [(number: Int, from: TimeInterval, to: TimeInterval, text: String)]? {
        let pattern = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
        guard let matches = content.matches(forPattern: pattern) else { return nil }

        var subtitles = [(number: Int, from: TimeInterval, to: TimeInterval, text: String)]()
        
        // iterate over every subtitle entry
        for match in matches {
            // 762\n01:03:07.007 --> 01:03:11.024\nOp 2doc.nl vindt u meer dan 1000 documentaires, interviews en tips.
            guard let group = content.substring(withNSRange: match.range), let subtitle = parse(subtitleGroup: group) else { continue }
            subtitles.append(subtitle)
        }
        
        return subtitles
    }
    
    private func parse(subtitleGroup group: String) -> (number: Int, from: TimeInterval, to: TimeInterval, text: String)? {
        let elements = group.components(separatedBy: "\n")
        guard elements.count == 3 else { return nil }
        let timeComponents = elements[1].components(separatedBy: " --> ")

        guard
            let number = Int(elements[0]),
            timeComponents.count == 2,
            let from = parse(timeComponent: timeComponents[0]),
            let to = parse(timeComponent: timeComponents[1]) else { return nil }
        
        let text = elements[2]
        
        return (number: number, from: from, to: to, text: text)
    }
    
    private func parse(timeComponent component: String) -> TimeInterval? {
        let pattern = "\\d+[:|\\.]?"
        guard
            let matches = component.matches(forPattern: pattern),
            matches.count == 4,
            let h = component.substring(withNSRange: matches[0].range, stripPattern: "[:\\.]?"),
            let hours = Double(h),
            let m = component.substring(withNSRange: matches[1].range, stripPattern: "[:\\.]?"),
            let minutes = Double(m),
            let s = component.substring(withNSRange: matches[2].range, stripPattern: "[:\\.]?"),
            let seconds = Double(s),
            let ms = component.substring(withNSRange: matches[3].range, stripPattern: "[:\\.]?"),
            let milliseconds = Double(ms)
            else { return nil }
        
        return hours * 3600.0 + minutes * 60.0 + seconds + milliseconds / 1000
    }
    
    private func displaySubtitles(atTime time: CMTime) {
        // only show subtitles if they are enabled
        guard closedCaptioningEnabled else { return }
        
        // get the subtitle line for this point in time
        guard let subtitles = self.subtitles, let subtitle = subtitles.filter({ $0.to >= time.seconds && $0.from <= time.seconds }).first else {
            label.text = nil
            return
        }
        
        if let currentNumber = currentSubtitleNumber, subtitle.number == currentNumber {
            // this subtitle is already being shown
            return
        }
        
        currentSubtitleNumber = subtitle.number
        label.text = subtitle.text
        
        guard isDebuggingEnabled else { return }
        
        DDLogDebug("Subtitle \(subtitle.number) at \(time.seconds)s: '\(subtitle.text)'")
    }
}
