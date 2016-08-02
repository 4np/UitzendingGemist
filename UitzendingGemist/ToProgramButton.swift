//
//  ToProgramButton.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 20/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

class ToProgramButton: UIButton {
//    let focusedImageName = "Television-black"
//    let unfocusedImageName = "Television-white"
    
//    internal var televisionImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let televisionImageView = UIImageView(image: UIImage(named: self.unfocusedImageName))
//        self.addSubview(televisionImageView)
//        self.televisionImageView = televisionImageView
    }
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        
//        self.televisionImageView?.image = UIImage(named: self.focused ? self.focusedImageName : self.unfocusedImageName)
//        self.televisionImageView?.adjustsImageWhenAncestorFocused
    }
}
