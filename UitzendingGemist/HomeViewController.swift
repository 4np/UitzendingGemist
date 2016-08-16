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

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var tipsCollectionView: UICollectionView!
    @IBOutlet weak private var onDeckCollectionView: UICollectionView!
    
    private var tips = [NPOTip]()
    private var onDeck = [NPOEpisode]()
    private var onDeckPrograms: [(program: NPOProgram, mostRecentUnwatchedEpisode: NPOEpisode, unwatchedEpisodeCount: Int)] = []
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to background image
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = backgroundImageView.bounds
        backgroundImageView.addSubview(visualEffectView)

        // update collection views
        tipsCollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh collections
        refresh()
        
        // check for version update
        checkForUpdate()
    }
    
    //MARK: Version check
    
    private func checkForUpdate() {
        // update check
        UpdateManager.sharedInstance.updateAvailable() { [weak self] latestRelease, currentVersion in
            // update available, show an alert
            let latestVersion = latestRelease?.version ?? UitzendingGemistConstants.unknownText
            let downloadURL = latestRelease?.url ?? UitzendingGemistConstants.unknownText
            let thisVersion = currentVersion ?? UitzendingGemistConstants.unknownText
            let alertText = String.localizedStringWithFormat(UitzendingGemistConstants.updateAvailableText, latestVersion, downloadURL, thisVersion)
            let alertController = UIAlertController(title: UitzendingGemistConstants.updateAvailableTitle, message: alertText, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: UitzendingGemistConstants.okayButtonText, style: .Cancel) { _ in
                alertController.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(cancelAction)
            self?.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    //MARK: Networking
    
    private func getData(withCompletion completed: (tips: [NPOTip], onDeck: [(program: NPOProgram, mostRecentUnwatchedEpisode: NPOEpisode, unwatchedEpisodeCount: Int)], errors: [NPOError]) -> ()) {
        var tips = [NPOTip]()
        var onDeck: [(program: NPOProgram, mostRecentUnwatchedEpisode: NPOEpisode, unwatchedEpisodeCount: Int)] = []
        var errors = [NPOError]()
        
        // create dispatch group
        let group = dispatch_group_create()
        
        // get tips
        dispatch_group_enter(group)
        NPOManager.sharedInstance.getTips() { items, error in
            defer { dispatch_group_leave(group) }
            
            if let items = items {
                tips = items
            } else if let error = error {
                errors.append(error)
            }
        }
        
        // get the most recent unwatched episodes of favorite programs
        dispatch_group_enter(group)
        NPOManager.sharedInstance.getDetailedFavoritePrograms() { programs, error in
            defer { dispatch_group_leave(group) }
            
            guard let programs = programs else {
                return
            }
            
            let sortedPrograms = programs.sort { $0.numberOfWatchedEpisodes > $1.numberOfWatchedEpisodes }
            
            // iterate over programs
            for program in sortedPrograms {
                let unwatchedEpisodes = program.episodes?.filter({ $0.watched != .Fully })
                if let mostRecentUnwatchedEpisode = unwatchedEpisodes?.first {
                    let tuple = (program: program, mostRecentUnwatchedEpisode: mostRecentUnwatchedEpisode, unwatchedEpisodeCount: unwatchedEpisodes?.count ?? 0)
                    onDeck.append(tuple)
                }
            }
        }
        
        // done
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completed(tips: tips, onDeck: onDeck, errors: errors)
        }
    }
    
    private func refresh() {
        getData() { [weak self] tips, onDeck, errors in
            guard let strongSelf = self else {
                return
            }
            
            // set initial background image?
            if strongSelf.backgroundImageView.image == nil, let firstTip = tips.first {
                firstTip.getImage(ofSize: strongSelf.backgroundImageView.frame.size) { image, _, _ in
                    strongSelf.backgroundImageView.image = image
                }
            }
        
            // store on deck programs
            strongSelf.onDeckPrograms = onDeck
            
            // update collection views
            strongSelf.tipsCollectionView.update(usingTips: &strongSelf.tips, withNewTips: tips)
            strongSelf.onDeckCollectionView.update(usingEpisodes: &strongSelf.onDeck, withNewEpisodes: onDeck.map { $0.mostRecentUnwatchedEpisode })
        }
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            case tipsCollectionView:
                return tips.count
            case onDeckCollectionView:
                return onDeck.count
            default:
                return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        switch collectionView {
            case tipsCollectionView:
                cell = dequeueTipCell(forCollectionView: collectionView, andIndexPath: indexPath)
            case onDeckCollectionView:
                cell = dequeueOnDeckCell(forCollectionView: collectionView, andIndexPath: indexPath)
            default:
                cell = UICollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Segues.HomeToEpisodeDetails.rawValue, sender: collectionView)
    }
    
    // swiftlint:disable force_cast
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath else {
            return
        }
        
        let image: NPOImage?
        switch collectionView {
            case tipsCollectionView:
                image = tips[indexPath.row]
                break
            case onDeckCollectionView:
                image = onDeck[indexPath.row]
                break
            default:
                image = nil
                break
        }
        
        image?.getImage(ofSize: self.backgroundImageView.frame.size) { [weak self] image, _, _ in
            self?.backgroundImageView.image = image
        }
    }
    // swiftlint:enable force_cast
    
    //MARK: Tips
    
    //swiftlint:disable force_cast
    private func dequeueTipCell(forCollectionView collectionView: UICollectionView, andIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.Tip.rawValue, forIndexPath: indexPath) as! TipCollectionViewCell
        cell.configure(withTip: self.tips[indexPath.row])
        return cell
    }
    //swiftlint:enable force_cast
    
    //MARK: On Deck
    
    //swiftlint:disable force_cast
    private func dequeueOnDeckCell(forCollectionView collectionView: UICollectionView, andIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.OnDeck.rawValue, forIndexPath: indexPath) as! OnDeckCollectionViewCell
        let row = indexPath.row
        
        if row >= 0 && row < onDeck.count {
            let episode = onDeck[row]
            let program = onDeckPrograms[row].program
            let count = onDeckPrograms[row].unwatchedEpisodeCount
            
            cell.configure(withProgram: program, unWachtedEpisodeCount: count, andEpisode: episode)
        }
        
        return cell
    }
    //swiftlint:enable force_cast

    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == Segues.HomeToEpisodeDetails.rawValue, let collectionView = sender as? UICollectionView, indexPath = collectionView.indexPathsForSelectedItems()?.first, vc = segue.destinationViewController as? EpisodeViewController else {
            return
        }
        
        if collectionView == tipsCollectionView {
            let tip = tips[indexPath.row]
            vc.configure(withTip: tip)
        } else if collectionView == onDeckCollectionView {
            let episode = onDeck[indexPath.row]
            vc.configure(withEpisode: episode)
        }
    }
}
