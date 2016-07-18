//
//  ProgramCollectionViewCell.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 18/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import Alamofire
import CocoaLumberjack

class ProgramCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var programImageView: UIImageView!
    @IBOutlet weak private var programNameLabel: UILabel!
    
    weak var request: NPORequest?
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //self.request?.cancel()
        self.programNameLabel.text = nil
        self.programImageView.image = nil
    }
    
    //MARK: Focus engine
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        self.programImageView.adjustsImageWhenAncestorFocused = self.focused
    }
    
    //MARK: Configuration
    
    func configure(withProgram program: NPOProgram) {
        let size = self.programImageView.frame.size
        
        self.programNameLabel.text = program.name
        
        self.request = program.getImage(ofSize: size) { [weak self] image, error, request in
            guard let image = image else {
                DDLogDebug("Could not fetch program image (\(error))")
                return
            }
            
            guard request == self?.request else {
                // this is the result of another cell, ignore it
                return
            }
            
            self?.programImageView.image = image
        }
    }
}
