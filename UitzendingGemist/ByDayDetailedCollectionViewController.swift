//
//  ByDayDetailedCollectionViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 02/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ByDayDetailedCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var episodeCollectionView: UICollectionView!
    
    private var episodes = [NPOEpisode]()
    
    //MARK: Configuration
    
    //swiftlint:disable force_cast
    func configure(withDate date: NSDate) {
        NPOManager.sharedInstance.getEpisodes(forDate: date, filterReruns: true) { [weak self] episodes, error in
            guard let episodes = episodes, strongSelf = self else {
                DDLogError("Could not fetch episodes for \(date) (\(error))")
                return
            }
            
            strongSelf.episodeCollectionView.update(usingEpisodes: &strongSelf.episodes, withNewEpisodes: episodes)
            
            // initial configuration
            let vc = self?.splitViewController as! ByDaySplitViewController
            vc.initialConfigure(withEpisode: episodes.first)
        }
    }
    //swiftlint:enable force_cast
    
    //MARK:
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    // swiftlint:disable force_cast
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.DayDetail.rawValue, forIndexPath: indexPath) as! ByDayDetailedCollectionViewCell
        cell.configure(withEpisode: episodes[indexPath.row])
        return cell
    }
    // swiftlint:enable force_cast
    
    // swiftlint:disable force_cast
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath else {
            return
        }

        let episode = episodes[indexPath.row]
        let vc = self.splitViewController as! ByDaySplitViewController
        vc.configure(withEpisode: episode)
    }
    // swiftlint:enable force_cast
    
    // swiftlint:disable force_cast
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = self.splitViewController as! ByDaySplitViewController
        vc.didSelect(episode: episodes[indexPath.row])
    }
    // swiftlint:enable force_cast
}
