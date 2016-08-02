//
//  ProgramRootTableViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 26/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ProgramRootTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.nameLabel.text = nil
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        
        nameLabel.textColor = focused ? UIColor.blackColor() : UIColor.whiteColor()
        nameLabel.shadowColor = focused ? UIColor.lightShadow : UIColor.blackColor()
        nameLabel.shadowOffset = focused ? CGSize(width: 2, height: 1) : CGSize(width: 1, height: 1)
    }
    
    //MARK: Configuration
    
    internal func configure(withName name: String, andCount count: Int) {
        self.nameLabel.text = name.capitalizedString
    }
}
