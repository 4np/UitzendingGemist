//
//  ByDayDetailedCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 02/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit

class ByDayDetailedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var episodeNameAndTimeLabel: UILabel!

    private var imageRequest: NPORequest?
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        episodeImageView.image = nil
        programNameLabel.text = nil
        episodeNameAndTimeLabel.text = nil
    }
    
    //MARK: Configuration
    
    func configure(withEpisode episode: NPOEpisode) {
        let names = episode.getNames()
        programNameLabel.text = names.programName
        episodeNameAndTimeLabel.text = names.episodeNameAndInfo
        
        // get image
        imageRequest = episode.getImage(ofSize: episodeImageView.frame.size) { [weak self] image, error, request in
            guard let imageRequest = self?.imageRequest where request == imageRequest else {
                return
            }
            
            self?.episodeImageView.image = image
        }
    }
    
    //MARK: Focus engine
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        episodeImageView.adjustsImageWhenAncestorFocused = self.focused
    }
}
