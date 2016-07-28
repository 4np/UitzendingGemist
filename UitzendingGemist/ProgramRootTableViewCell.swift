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

class ProgramRootTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.nameLabel.text = nil
        self.countLabel.text = nil
    }
    
    //MARK: Configuration
    
    internal func configure(withName name: String, andCount count: Int) {
        self.nameLabel.text = name.capitalizedString
        self.countLabel.text = "(\(count))"
    }
}
