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
    @IBOutlet weak fileprivate var episodeImageView: UIImageView!
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var episodeRequest: NPORequest?
    weak var programRequest: NPORequest?
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.episodeImageView.image = nil
        self.episodeNameLabel.text = nil
        self.dateLabel.text = nil
    }
    
    // MARK: Focus engine
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.episodeImageView.adjustsImageWhenAncestorFocused = self.isFocused
    }
    
    // MARK: Configuration
    
    func configure(withEpisode episode: NPOEpisode, andProgram program: NPOProgram?) {
        self.episodeNameLabel.text = episode.getDisplayName()
        self.dateLabel.text = episode.broadcastedDisplayValue
        
        // Somehow in tvOS 10 / Xcode 8 / Swift 3 the frame will initially be 1000x1000
        // causing the images to look compressed so hardcode the dimensions for now...
        // TODO: check if this is solved in later releases...
        //let size = self.episodeImageView.frame.size
        let size = CGSize(width: 375, height: 211)
        
        // get image
        self.episodeRequest = episode.getImage(ofSize: size) { [weak self] image, _, request in
            guard let image = image else {
                // fallback to program
                self?.fetchImage(byProgram: program)
                return
            }
            
            guard request == self?.episodeRequest else {
                // this is the result of another cell, ignore it
                return
            }
            
            self?.episodeImageView.image = image
        }
    }
    
    fileprivate func fetchImage(byProgram program: NPOProgram?) {
        // Somehow in tvOS 10 / Xcode 8 / Swift 3 the frame will initially be 1000x1000
        // causing the images to look compressed so hardcode the dimensions for now...
        // TODO: check if this is solved in later releases...
        //let size = self.episodeImageView.frame.size
        let size = CGSize(width: 375, height: 211)
        
        self.programRequest = program?.getImage(ofSize: size) { [weak self] image, _, request in
            guard request == self?.programRequest else {
                // this is the result of another cell, ignore it
                return
            }
            
            self?.episodeImageView.image = image
        }
    }
}
