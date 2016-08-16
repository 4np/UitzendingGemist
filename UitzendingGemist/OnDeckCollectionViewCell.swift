//
//  OnDeckCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 16/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class OnDeckCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var programNameLabel: UILabel!
    @IBOutlet weak private var episodeNameLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.programNameLabel.text = nil
        self.episodeNameLabel.text = nil
        self.dateLabel.text = nil
    }
    
    //MARK: Focus engine
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        self.imageView.adjustsImageWhenAncestorFocused = self.focused
    }
    
    //MARK: Configuration
    
    internal func configure(withProgram program: NPOProgram, unWachtedEpisodeCount unwatchedCount: Int, andEpisode episode: NPOEpisode) {
        self.programNameLabel.text = program.getDisplayNameWithFavoriteIndicator()
        self.programNameLabel.textColor = program.getDisplayColor()
        self.episodeNameLabel.text = episode.getDisplayName()
        self.dateLabel.text = episode.broadcastedDisplayValue
        
        episode.getImage(ofSize: imageView.frame.size) { [weak self] image, _, _ in
            self?.imageView.image = image
        }
    }
}
