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
import CocoaLumberjack

class ProgramDetailedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var programImageView: UIImageView!
    @IBOutlet weak var programNameLabel: UILabel!
    
    fileprivate var imageRequest: NPORequest?
    
    // MARK: Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        programImageView.image = nil 
    }
    
    // MARK: Configuration
    
    func configure(withProgram program: NPOProgram) {
        programNameLabel.text = program.getDisplayName()
        programNameLabel.textColor = program.getDisplayColor()
        
        // Somehow in tvOS 10 / Xcode 8 / Swift 3 the frame will initially be 1000x1000
        // causing the images to look compressed so hardcode the dimensions for now...
        // TODO: check if this is solved in later releases...
        //let size = programImageView.frame.size
        let size = CGSize(width: 375, height: 211)
        
        // get image
        imageRequest = program.getImage(ofSize: size) { [weak self] image, error, request in
            guard let imageRequest = self?.imageRequest, request == imageRequest else {
                return
            }
            
            self?.programImageView.image = image
        }
    }
    
    // MARK: Focus engine
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        programImageView.adjustsImageWhenAncestorFocused = self.isFocused
    }
}
