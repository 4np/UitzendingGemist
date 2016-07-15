//
//  HomeViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 15/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack
import AVKit

enum CollectionViewCells: String {
    case Tip = "tipCollectionViewCell"
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak private var tipsCollectionView: UICollectionView!
    
    private var tips = [NPOTip]() {
        didSet {
            self.tipsCollectionView.reloadData()
        }
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchTips()
    }

    
    //MARK: Networking
    
    private func fetchTips() {
        NPOManager.sharedInstance.getTips() { [weak self] tips, error in
            guard let tips = tips else {
                DDLogError("Error fetching tips (\(error))")
                return
            }
            
            self?.tips = tips
        }
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tips.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let identifier = CollectionViewCells.Tip.rawValue

        let cell = tipsCollectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        
        guard let tipCell = cell as? TipCollectionViewCell else {
            DDLogError("could not cast cell")
            return cell
        }
        
        tipCell.configure(withTip: self.tips[row])
        return tipCell
    }
    
    //MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tip = self.tips[indexPath.row]
        
        tip.getVideoStream() { [weak self] url, error in
            guard let url = url else {
                DDLogError("Could not get video stream (\(error))")
                return
            }
            
            self?.playVideo(withURL: url)
        }
    }
    
    //MARK: Player
    
    func playVideo(withURL url: NSURL) {
        // set up player
        let player = AVPlayer(URL: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
//        // (re)set play data
//        episode.watchDuration = 0
//        
//        // observe player
//        let interval = CMTimeMakeWithSeconds(1, 1) // 1 second
//        player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { time in
//            let seconds = Int(time.seconds)
//            
//            guard seconds > episode.watchDuration else {
//                return
//            }
//            
//            episode.watchDuration = seconds
//        }
        
        // present player
        self.presentViewController(playerViewController, animated: true) {
            DDLogDebug("playing video file from \(url.absoluteString)")
            
            playerViewController.player?.play()
        }
    }
}
