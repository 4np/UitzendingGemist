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
    @IBOutlet weak fileprivate var imageView: UIImageView!
    @IBOutlet weak fileprivate var programNameLabel: UILabel!
    @IBOutlet weak fileprivate var episodeNameLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    
    // MARK: Lifecycle
    
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
    
    // MARK: Focus engine
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.imageView.adjustsImageWhenAncestorFocused = self.isFocused
    }
    
    // MARK: Configuration
    
    internal func configure(withProgram program: NPOProgram, unWachtedEpisodeCount unwatchedCount: Int, andEpisode episode: NPOEpisode) {
        self.programNameLabel.text = program.getDisplayNameWithFavoriteIndicator()
        self.programNameLabel.textColor = program.getDisplayColor()
        self.episodeNameLabel.text = episode.getDisplayName()
        self.dateLabel.text = episode.broadcastedDisplayValue
        
        // Somehow in tvOS 10 / Xcode 8 / Swift 3 the frame will initially be 1000x1000
        // causing the images to look compressed so hardcode the dimensions for now...
        // TODO: check if this is solved in later releases...
        //let size = self.imageView.frame.size
        let size = CGSize(width: 375, height: 211)
        
        _ = episode.getImage(ofSize: size) { [weak self] image, _, _ in
            self?.imageView.image = image
        }
    }
}
