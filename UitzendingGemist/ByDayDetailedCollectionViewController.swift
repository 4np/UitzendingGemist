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
    private var date: Date?
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // observe when we are foregrounded
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func applicationWillEnterForeground() {
        guard let date = date else { return }
        configure(withDate: date)
    }
    
    // MARK: Configuration
    
    //swiftlint:disable force_cast
    func configure(withDate date: Date) {
        self.date = date

        _ = NPOManager.sharedInstance.getEpisodes(forDate: date, filterReruns: true) { [weak self] episodes, error in
            guard let episodes = episodes, let strongSelf = self else {
                DDLogError("Could not fetch episodes for \(date) (\(String(describing: error)))")
                return
            }
            
            strongSelf.update(episodeCollectionView: strongSelf.episodeCollectionView, withNewEpisodes: episodes)
            
            // initial configuration
            let vc = self?.splitViewController as! ByDaySplitViewController
            vc.initialConfigure(withEpisode: episodes.first)
        }
    }
    //swiftlint:enable force_cast
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCells.dayDetail.rawValue, for: indexPath) as! ByDayDetailedCollectionViewCell
        cell.configure(withEpisode: episodes[indexPath.row])
        return cell
    }
    // swiftlint:enable force_cast
    
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath else {
            return
        }

        let episode = episodes[indexPath.row]
        let vc = self.splitViewController as! ByDaySplitViewController
        vc.configure(withEpisode: episode)
    }
    // swiftlint:enable force_cast
    
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.splitViewController as! ByDaySplitViewController
        vc.didSelect(episode: episodes[indexPath.row])
    }
    // swiftlint:enable force_cast
    
    fileprivate func update(episodeCollectionView: UICollectionView, withNewEpisodes newEpisodes: [NPOEpisode]) {
        // first determine the old / removed episodes and remove them
        let old = episodes.enumerated().filter({ !newEpisodes.contains($0.element) }).reversed()
        let oldIndexPaths = old.map { IndexPath(row: $0.offset, section: 0) }
        for oldEpisode in old {
            guard oldEpisode.offset >= 0 && oldEpisode.offset < episodes.count else {
                continue
            }
            
            episodes.remove(at: oldEpisode.offset)
        }
        episodeCollectionView.deleteItems(at: oldIndexPaths)
        
        // determine the new / added episodes and insert them
        let new = newEpisodes.enumerated().filter({ !episodes.contains($0.element) })
        let newIndexPaths = new.map { IndexPath(row: $0.offset, section: 0) }
        for newEpisode in new {
            episodes.insert(newEpisode.element, at: newEpisode.offset)
        }
        episodeCollectionView.insertItems(at: newIndexPaths)
        
        // re-order cells (if needed)
        var done = false
        while !done {
            for newEpisode in newEpisodes.enumerated() {
                guard let offset = episodes.index(of: newEpisode.element), offset != newEpisode.offset else {
                    done = true
                    continue
                }
                
                // move cell
                let from = IndexPath(row: offset, section: 0)
                let to = IndexPath(row: newEpisode.offset, section: 0)
                episodeCollectionView.moveItem(at: from, to: to)
                
                // move array element
                episodes.remove(at: offset)
                episodes.insert(newEpisode.element, at: newEpisode.offset)
                done = false
                break
            }
            
            done = true
        }
    }
}
