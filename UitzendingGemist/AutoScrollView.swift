//
//  AutoScrollView.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 20/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

class AutoScrollView: UIScrollView {
    fileprivate let scrollStep: CGFloat = 10
    fileprivate let scrollDelay = 0.1
    fileprivate let startDelay = 5.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        startDelayedScroll()
    }
    
    @objc fileprivate func startDelayedScroll() {
        scrollToTop()
        Timer.scheduledTimer(timeInterval: self.startDelay, target: self, selector: #selector(scroll), userInfo: nil, repeats: false)
    }
    
    fileprivate func scrollToTop() {
        let offset = CGPoint(x: 0, y: 0)
        self.setContentOffset(offset, animated: true)
    }
    
    @objc fileprivate func scroll() {
        let height = self.frame.height
        
        guard let contentHeight = self.subviews.first?.intrinsicContentSize.height , contentHeight > height else {
            return
        }

        let scrollHeight = contentHeight - height + self.scrollStep + self.scrollStep
        let y = self.contentOffset.y + self.scrollStep
        
        guard y < scrollHeight else {
            Timer.scheduledTimer(timeInterval: self.startDelay, target: self, selector: #selector(startDelayedScroll), userInfo: nil, repeats: false)
            return
        }
        
        let offset = CGPoint(x: 0, y: y)
        self.setContentOffset(offset, animated: true)
        
        Timer.scheduledTimer(timeInterval: self.scrollDelay, target: self, selector: #selector(scroll), userInfo: nil, repeats: false)
    }
}
