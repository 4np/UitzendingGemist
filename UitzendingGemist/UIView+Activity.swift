//
//  UIView+Activity.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 20/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    private struct AssociatedKeys {
        static var overlayView: UIView?
    }
    
    //MARK: Loading
    
    func startLoading() {
        startLoading(nil)
    }
    
    func startLoading(backgroundImage: UIImage?) {
        if let overlayView = objc_getAssociatedObject(self, &AssociatedKeys.overlayView) as? UIView {
            // show overlay view
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                overlayView.alpha = 1.0
            }, completion: { finished in
                    //overlayView.removeFromSuperview()
            })
        } else {
            // create new overlay view
            let overlayView = UIView(frame: self.bounds)
            overlayView.backgroundColor = UIColor.clearColor()
            
            // add backgroundImage if we have it
            if let image = backgroundImage {
                let imageView = UIImageView(frame: overlayView.bounds)
                imageView.image = image
                overlayView.addSubview(imageView)
            }
            
            // blur effect view
            let blurEffect = UIBlurEffect(style: .Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = overlayView.bounds
            
            // spinner
            let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .WhiteLarge)
            activityIndicator.center = overlayView.center
            activityIndicator.startAnimating()
            
            // feedback
            let feedbackY = activityIndicator.center.y + activityIndicator.frame.height
            let feedbackLabel = UILabel(frame: CGRect(x: 0, y: feedbackY, width: bounds.width, height: 100))
            feedbackLabel.text = UitzendingGemistConstants.waitText
            feedbackLabel.textColor = UIColor.orangeColor()
            feedbackLabel.textAlignment = .Center
            feedbackLabel.font = UIFont.systemFontOfSize(42.0)
            
            // add views
            blurEffectView.addSubview(activityIndicator)
            overlayView.addSubview(blurEffectView)
            overlayView.addSubview(feedbackLabel)
            
            // set alpha to 0
            overlayView.alpha = 0.0
            
            // overlay view add as subview
            self.addSubview(overlayView)
            objc_setAssociatedObject(self, &AssociatedKeys.overlayView, overlayView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // start animating
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                overlayView.alpha = 1.0
            }, completion: { finished in
            })
        }
    }
    
    func stopLoading() {
        if let overlayView = objc_getAssociatedObject(self, &AssociatedKeys.overlayView) as? UIView {
            // hide overlay view
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                overlayView.alpha = 0.0
                }, completion: { finished in
                    //overlayView.removeFromSuperview()
            })
        }
    }
}
