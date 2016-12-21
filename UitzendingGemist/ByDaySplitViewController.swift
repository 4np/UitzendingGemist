//
//  ByDaySplitViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 02/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ByDaySplitViewController: UISplitViewController {
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
        let dvc = viewControllers[1] as! ByDayDetailedCollectionViewController
        
        // determine new frames
        let nvcWidth: CGFloat = 380
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
    
    internal func initialConfigure(withEpisode episode: NPOEpisode?) {
        guard let episode = episode, backgroundImageView.image == nil else {
            return
        }
        
        configure(withEpisode: episode)
    }
    
    internal func configure(withEpisode episode: NPOEpisode) {
        self.imageRequest = episode.getImage(ofSize: backgroundImageView.frame.size) { [weak self] image, _, request in
            guard let imageRequest = self?.imageRequest, request == imageRequest else {
                return
            }
            
            self?.backgroundImageView.image = image
        }
    }
    
    internal func didSelect(episode: NPOEpisode) {
        // launch the EpisodeViewController (unfortunately you cannot segue
        // from a SplitViewController elsewhere so this is a workaround)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rvc = appDelegate.window?.rootViewController,
            let storyboard = rvc.storyboard, let vc = storyboard.instantiateViewController(withIdentifier: ViewControllers.EpisodeViewController.rawValue) as? EpisodeViewController {
            vc.configure(withEpisode: episode)
            tabBarController?.show(vc, sender: nil)
        }
    }
}
