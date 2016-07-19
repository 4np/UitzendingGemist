//
//  ProgramListSectionHeaderView.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 19/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit

class ProgramListSectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    //MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add blur effect to label
        let blurEffect = UIBlurEffect(style: .Dark)
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        self.headerBackgroundView.addSubview(vibrancyEffectView)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.headerLabel.text = nil
    }
    
    //MARK: Configuration
    
    func configure(withText text: String) {
        self.headerLabel.text = text.uppercaseString
    }
}
