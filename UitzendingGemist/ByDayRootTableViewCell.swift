//
//  ByDayRootTableViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 01/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ByDayRootTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.nameLabel.text = nil
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        
        nameLabel.textColor = focused ? UIColor.blackColor() : UIColor.whiteColor()
    }
    
    //MARK: Configuration
    
    internal func configure(withName name: String) {
        self.nameLabel.text = name.capitalizedString
    }
}
