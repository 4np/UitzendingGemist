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
        // Somehow in tvOS 10 / Xcode 8 / Swift 3 the frame will initially be 1000x1000
        // causing the images to look compressed so hardcode the dimensions for now...
        // TODO: check if this is solved in later releases...
        //let size = self.imageView.frame.size
        let size = CGSize(width: 548, height: 320)
        
        _ = tip.getImage(ofSize: size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not fetch image for tip (\(error))")
                return
            }

            // add a gradient to improve readability
            if let gradientImage = image.imageWithGradient() {
                self?.imageView.image = gradientImage
            } else {
                self?.imageView.image = image
            }
        }
    }
}
