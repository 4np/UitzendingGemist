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
    @IBOutlet weak private var stillImageView: UIImageView!
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.stillImageView.image = nil
    }
    
    //MARK: Focus engine
    
    override func canBecomeFocused() -> Bool {
        return false
    }
    
    //MARK: Configuration
    
    func configure(withStill still: NPOStill) {
        still.getImage(ofSize: self.stillImageView.frame.size) { [weak self] image, error in
            guard let image = image else {
                DDLogError("Could not fetch still image (\(error))")
                return
            }
            
            self?.stillImageView.image = image
        }
    }
}
