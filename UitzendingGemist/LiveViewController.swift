//
//  LiveViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 21/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import NPOKit
import CocoaLumberjack

class LiveViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var liveCollectionView: UICollectionView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.liveCollectionView.reloadData()
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NPOLive.all.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.Live.rawValue, forIndexPath: indexPath)
        
        guard let liveCell = cell as? LiveCollectionViewCell where indexPath.row >= 0 && indexPath.row < NPOLive.all.count else {
            return cell
        }
        
        let channel = NPOLive.all[indexPath.row]
        liveCell.configure(withLiveChannel: channel)
        return liveCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row >= 0 && indexPath.row < NPOLive.all.count else {
            return
        }
        
        let channel = NPOLive.all[indexPath.row]
        self.play(liveChannel: channel)
    }
    
    //MARK: Playing
    
    private func play(liveChannel channel: NPOLive) {
        // show progress hud
        self.view.startLoading()
        
        NPOManager.sharedInstance.getVideoStream(forLiveChannel: channel) { [weak self] url, error in
            // hide progress hud
            self?.view.stopLoading()
            
            guard let url = url else {
                DDLogError("Could not play live stream (\(error))")
                return
            }
            
            // set up player
            let player = AVPlayer(URL: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            // present player
            self?.presentViewController(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }
}
