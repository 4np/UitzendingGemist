//
//  LiveCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 21/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class LiveCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var upcommingLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.channelLogoImageView.image = nil
        self.channelImageView.image = nil
        self.currentLabel.text = nil
        self.upcommingLabel.text = nil
    }
    
    //MARK: Focus engine
    
    override var canBecomeFocused : Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.channelImageView.adjustsImageWhenAncestorFocused = self.isFocused
        self.channelLogoImageView.adjustsImageWhenAncestorFocused = self.isFocused
    }
    
    //MARK: Configuration
    
    internal func configure(withLiveChannel channel: NPOLive, andGuide broadcasts: [NPOBroadcast]?) {
        // set the logo image
        self.channelLogoImageView.image = UIImage(named: "\(channel.rawValue)")
        
        // get the channel image
        let channelImage = UIImage(named: "\(channel.rawValue)_Channel")
        
        // get the current broadcast for this channel
        if let currentBroadcast = self.getCurrentBroadcast(forGuide: broadcasts) {
            self.fetchImage(forEpisode: currentBroadcast.episode, withFallbackImage: channelImage)
            self.currentLabel.text = self.getCurrentText(forBroadcast: currentBroadcast)
        } else {
            // in between broadcasts; probably a commercial break
            self.channelImageView.image = channelImage
            self.currentLabel.text = String.localizedStringWithFormat(UitzendingGemistConstants.currentBroadcast, UitzendingGemistConstants.commercials)
        }
        
        // get the next broadcast for this channel
        if let nextBroadcast = self.getNextBroadcast(forGuide: broadcasts) {
            self.upcommingLabel.text = self.getUpcomingText(forBroadcast: nextBroadcast)
        } else {
            // unknown
            self.upcommingLabel.text = nil
        }
    }
    
    //MARK: Broadcast texts
    
    fileprivate func getCurrentText(forBroadcast broadcast: NPOBroadcast) -> String {
        let name = (broadcast.episode?.program?.name ?? broadcast.episode?.name) ?? UitzendingGemistConstants.unknownText
        return String.localizedStringWithFormat(UitzendingGemistConstants.currentBroadcast, name)
    }
    
    fileprivate func getUpcomingText(forBroadcast broadcast: NPOBroadcast) -> String {
        let name = (broadcast.episode?.program?.name ?? broadcast.episode?.name) ?? UitzendingGemistConstants.unknownText
        
        guard let starts = broadcast.starts else {
            return String.localizedStringWithFormat(UitzendingGemistConstants.upcomingBroadcast, name)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: starts)
        return String.localizedStringWithFormat(UitzendingGemistConstants.upcomingBroadcastWithTime, timeString, name)
    }
    
    //MARK: Broadcast filtering
    
    fileprivate func getCurrentBroadcast(forGuide broadcasts: [NPOBroadcast]?) -> NPOBroadcast? {
        let now = Date()
        return broadcasts?.filter({ now.liesBetween(startDate: $0.starts, endDate: $0.ends) }).first
    }
    
    fileprivate func getNextBroadcast(forGuide broadcasts: [NPOBroadcast]?) -> NPOBroadcast? {
        let now = Date()
        return broadcasts?.filter({ now.lies(before: $0.starts) }).first
    }
    
    //MARK: Image fetching
    
    fileprivate func fetchImage(forEpisode episode: NPOEpisode?, withFallbackImage fallbackImage: UIImage?) {
        guard let episode = episode else {
            self.channelImageView.image = fallbackImage
            return
        }
        
        episode.getImage(ofSize: self.channelImageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                self?.fetchImage(forProgram: episode.program, withFallbackImage: fallbackImage)
                return
            }
            
            self?.channelImageView.image = image
        }
    }
    
    fileprivate func fetchImage(forProgram program: NPOProgram?, withFallbackImage fallbackImage: UIImage?) {
        guard let program = program else {
            self.channelImageView.image = fallbackImage
            return
        }
        
        program.getImage(ofSize: self.channelImageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                self?.channelImageView.image = fallbackImage
                return
            }
            
            self?.channelImageView.image = image
        }
    }
}
