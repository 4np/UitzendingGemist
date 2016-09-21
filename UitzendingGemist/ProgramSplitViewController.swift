//
//  ProgramSplitViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 27/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ProgramSplitViewController: UISplitViewController {
    fileprivate lazy var backgroundImageView: UIImageView = {
        // define frame
        let frame = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        
        // create image view
        let imageView = UIImageView(frame: frame)
        
        // add visual effect view
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = imageView.frame
        imageView.addSubview(visualEffectView)
        
        // add to image view to view
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        return imageView
    }()
    
    fileprivate var imageRequest: NPORequest?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //swiftlint:disable force_cast
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let nvc = viewControllers[0] as! UINavigationController
        let dvc = viewControllers[1] as! ProgramDetailedCollectionViewController
        
        // determine new frames
        let nvcWidth: CGFloat = 360
        let nvcChangeInX = nvc.view.frame.width - nvcWidth
        let nvcFrame = CGRect(origin: nvc.view.frame.origin, size: CGSize(width: nvcWidth, height: nvc.view.frame.size.height))
        nvc.view.frame = nvcFrame
        nvc.view.setNeedsLayout()

        let dvcWidth = view.frame.size.width - nvcWidth
        let dvcOrigin = CGPoint(x: dvc.view.frame.origin.x - nvcChangeInX, y: dvc.view.frame.origin.y)
        let dvcFrame = CGRect(origin: dvcOrigin, size: CGSize(width: dvcWidth, height: dvc.view.frame.size.height))
        dvc.view.frame = dvcFrame
        dvc.view.setNeedsLayout()
    }
    //swiftlint:enable force_cast
    
    // MARK: Configuration
    
    internal func configure(withProgram program: NPOProgram) {
        self.imageRequest = program.getImage(ofSize: backgroundImageView.frame.size) { [weak self] image, error, request in
            guard let imageRequest = self?.imageRequest, request == imageRequest else {
                return
            }
            
            self?.backgroundImageView.image = image
        }
    }
    
    // MARK: ProgramDetailedCollectionViewControllerDelegate
    
    internal func didSelect(program: NPOProgram) {
        // launch the ProgramViewController (unfortunately you cannot segue
        // from a SplitViewController elsewhere so this is a workaround)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rvc = appDelegate.window?.rootViewController,
            let storyboard = rvc.storyboard, let vc = storyboard.instantiateViewController(withIdentifier: ViewControllers.ProgramViewController.rawValue) as? ProgramViewController {
            vc.configure(withProgram: program)
            tabBarController?.show(vc, sender: nil)
        }
    }
}
