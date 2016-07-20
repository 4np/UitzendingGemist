//
//  EpisodeCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 19/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class EpisodeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var episodeImageView: UIImageView!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.episodeImageView.image = nil
        self.episodeNameLabel.text = nil
        self.dateLabel.text = nil
    }
    
    //MARK: Focus engine
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        self.episodeImageView.adjustsImageWhenAncestorFocused = self.focused
    }
    
    //MARK: Configuration
    
    func configure(withEpisode episode: NPOEpisode, andProgram program: NPOProgram?) {
        self.episodeNameLabel.text = episode.name
        self.dateLabel.text = episode.broadcastedDisplayValue
        
        // get image
        episode.getImage(ofSize: self.episodeImageView.frame.size) { [weak self] image, _, _ in
            guard let image = image else {
                self?.fetchImage(byProgram: program)
                return
            }
            
            self?.episodeImageView.image = image
        }
    }
    
    private func fetchImage(byProgram program: NPOProgram?) {
        program?.getImage(ofSize: self.episodeImageView.frame.size) { [weak self] image, _, _ in
            self?.episodeImageView.image = image
        }
    }
}
