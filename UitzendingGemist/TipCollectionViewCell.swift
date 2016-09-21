//
//  TipCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class TipCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak fileprivate var imageView: UIImageView!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.nameLabel.text = nil
        self.dateLabel.text = nil
    }
    
    // MARK: Focus engine
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.imageView.adjustsImageWhenAncestorFocused = self.isFocused
    }
    
    // MARK: Configuration
    
    internal func configure(withTip tip: NPOTip) {
        self.fetchImage(forTip: tip)
        self.nameLabel.text = tip.getDisplayName()
        self.dateLabel.text = tip.publishedDisplayValue
    }
    
    // MARK: Networking
    
    internal func fetchImage(forTip tip: NPOTip) {
        let size = self.imageView.frame.size
        
        tip.getImage(ofSize: size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not fetch image for tip (\(error))")
                return
            }

            self?.imageView.image = image
        }
    }
}
