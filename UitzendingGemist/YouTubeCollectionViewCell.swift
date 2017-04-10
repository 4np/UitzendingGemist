//
//  YouTubeCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 18/11/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class YouTubeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
        self.dateLabel.text = nil
        self.imageView.image = nil
    }
    
    // MARK: Focus engine
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.imageView.adjustsImageWhenAncestorFocused = self.isFocused
    }
    
    // MARK: Configuration
    
    func configure(withYouTubeVideo video: NPOYouTubeVideo) {
        self.titleLabel.text = video.title ?? String.unknownEpisodeName
        self.dateLabel.text = video.published?.daysAgoDisplayValue ?? ""
        
        fetchImage(forVideo: video)
    }
    
    fileprivate func fetchImage(forVideo video: NPOYouTubeVideo) {
        let size = CGSize(width: 375, height: 211)
        
        // get image
        _ = NPOManager.sharedInstance.getImage(forYouTubeVideo: video, ofSize: size) { [weak self] image, _ in
            guard let image = image else {
                return
            }
            
            self?.imageView.image = image
        }
    }
}
