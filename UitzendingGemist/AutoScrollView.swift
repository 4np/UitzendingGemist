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
    private let scrollStep: CGFloat = 10
    private let scrollDelay = 0.1
    private let startDelay = 5.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        startDelayedScroll()
    }
    
    @objc private func startDelayedScroll() {
        scrollToTop()
        NSTimer.scheduledTimerWithTimeInterval(self.startDelay, target: self, selector: #selector(scroll), userInfo: nil, repeats: false)
    }
    
    private func scrollToTop() {
        let offset = CGPoint(x: 0, y: 0)
        self.setContentOffset(offset, animated: true)
    }
    
    @objc private func scroll() {
        let height = self.frame.height
        
        guard let contentHeight = self.subviews.first?.intrinsicContentSize().height where contentHeight > height else {
            return
        }

        let scrollHeight = contentHeight - height + self.scrollStep + self.scrollStep
        let y = self.contentOffset.y + self.scrollStep
        
        guard y < scrollHeight else {
            NSTimer.scheduledTimerWithTimeInterval(self.startDelay, target: self, selector: #selector(startDelayedScroll), userInfo: nil, repeats: false)
            return
        }
        
        let offset = CGPoint(x: 0, y: y)
        self.setContentOffset(offset, animated: true)
        
        NSTimer.scheduledTimerWithTimeInterval(self.scrollDelay, target: self, selector: #selector(scroll), userInfo: nil, repeats: false)
    }
}
