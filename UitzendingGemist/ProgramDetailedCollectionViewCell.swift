//
//  ProgramDetailedCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 27/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit

class ProgramDetailedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var programImageView: UIImageView!
    @IBOutlet weak var programNameLabel: UILabel!
    
    private var imageRequest: NPORequest?
    
    //MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        programImageView.image = nil 
    }
    
    //MARK: Configuration
    
    func configure(withProgram program: NPOProgram) {
        self.programNameLabel.text = program.getDisplayName()
        self.programNameLabel.textColor = program.getDisplayColor()
        
        // get image
        imageRequest = program.getImage(ofSize: programImageView.frame.size) { [weak self] image, error, request in
            guard let imageRequest = self?.imageRequest where request == imageRequest else {
                return
            }
            
            self?.programImageView.image = image
        }
    }
    
    //MARK: Focus engine
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        self.programImageView.adjustsImageWhenAncestorFocused = self.focused
    }
}
