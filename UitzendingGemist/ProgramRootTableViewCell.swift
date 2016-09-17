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
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        nameLabel.textColor = isFocused ? UIColor.black : UIColor.white
        nameLabel.shadowColor = isFocused ? UIColor.lightShadow : UIColor.black
        nameLabel.shadowOffset = isFocused ? CGSize(width: 2, height: 1) : CGSize(width: 1, height: 1)
    }
    
    //MARK: Configuration
    
    internal func configure(withName name: String, andCount count: Int) {
        self.nameLabel.text = name.capitalized
    }
}
