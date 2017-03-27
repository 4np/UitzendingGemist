//
//  StillCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 18/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class StillCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak fileprivate var stillImageView: UIImageView!
    
    // MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stillImageView.image = nil
    }
    
    // MARK: Focus engine
    
    override var canBecomeFocused: Bool {
        return false
    }
    
    // MARK: Configuration
    
    func configure(withStill still: NPOStill) {
        // Somehow in tvOS 10 / Xcode 8 / Swift 3 the frame will initially be 1000x1000
        // causing the images to look compressed so hardcode the dimensions for now...
        // TODO: check if this is solved in later releases...
        //let size = self.stillImageView.frame.size
        let size = CGSize(width: 260, height: 146)
        
        _ = still.getImage(ofSize: size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not fetch still image (\(error))")
                return
            }
            
            self?.stillImageView.image = image
        }
    }
}
