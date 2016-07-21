//
//  LiveCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 21/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class LiveCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var channelImageView: UIImageView!
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.channelImageView.image = nil
    }
    
    //MARK: Focus engine
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        self.channelImageView.adjustsImageWhenAncestorFocused = self.focused
    }
    
    //MARK: Configuration
    
    internal func configure(withLiveChannel channel: NPOLive) {
        let imageName = "\(channel.rawValue)_Logo"
        self.channelImageView.image = UIImage(named: imageName)
    }
}
