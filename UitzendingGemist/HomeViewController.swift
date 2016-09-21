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
    @IBOutlet weak fileprivate var backgroundImageView: UIImageView!
    @IBOutlet weak fileprivate var tipsCollectionView: UICollectionView!
    @IBOutlet weak fileprivate var onDeckCollectionView: UICollectionView!
    
    fileprivate var tips = [NPOTip]()
    fileprivate var onDeck = [NPOEpisode]()
    fileprivate var onDeckPrograms: [(program: NPOProgram, mostRecentUnwatchedEpisode: NPOEpisode, unwatchedEpisodeCount: Int)] = []
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // update collection views
        tipsCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh collections
        refresh()
        
        // check for version update
        checkForUpdate()
    }
    
    // MARK: Version check
    
    fileprivate func checkForUpdate() {
        // update check
        UpdateManager.sharedInstance.updateAvailable() { [weak self] latestRelease, currentVersion in
            // update available, show an alert
            let latestVersion = latestRelease?.version ?? UitzendingGemistConstants.unknownText
            let downloadURL = latestRelease?.url
            let thisVersion = currentVersion ?? UitzendingGemistConstants.unknownText
            let downloadURLString = downloadURL?.absoluteString ?? UitzendingGemistConstants.unknownText
            let alertText = String.localizedStringWithFormat(UitzendingGemistConstants.updateAvailableText, latestVersion, downloadURLString, thisVersion)
            let alertController = UIAlertController(title: UitzendingGemistConstants.updateAvailableTitle, message: alertText, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: UitzendingGemistConstants.okayButtonText, style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(cancelAction)
            self?.present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: Networking
    
    fileprivate func getData(withCompletion completed: @escaping (_ tips: [NPOTip], _ onDeck: [(program: NPOProgram, mostRecentUnwatchedEpisode: NPOEpisode, unwatchedEpisodeCount: Int)], _ errors: [NPOError]) -> ()) {
        var tips = [NPOTip]()
        var onDeck: [(program: NPOProgram, mostRecentUnwatchedEpisode: NPOEpisode, unwatchedEpisodeCount: Int)] = []
        var errors = [NPOError]()
        
        // create dispatch group
        let group = DispatchGroup()
        
        // get tips
        group.enter()
        let _ = NPOManager.sharedInstance.getTips() { items, error in
            defer { group.leave() }
            
            if let items = items {
                tips = items
            } else if let error = error {
                errors.append(error)
            }
        }
        
        // get the most recent unwatched episodes of favorite programs
        group.enter()
        NPOManager.sharedInstance.getDetailedFavoritePrograms() { programs, error in
            defer { group.leave() }
            
            guard let programs = programs else {
                return
            }
            
            let sortedPrograms = programs.sorted { $0.numberOfWatchedEpisodes > $1.numberOfWatchedEpisodes }
            
            // iterate over programs
            for program in sortedPrograms {
                let unwatchedEpisodes = program.episodes?.filter({ $0.watched != .fully })
                if let mostRecentUnwatchedEpisode = unwatchedEpisodes?.first {
                    let tuple = (program: program, mostRecentUnwatchedEpisode: mostRecentUnwatchedEpisode, unwatchedEpisodeCount: unwatchedEpisodes?.count ?? 0)
                    onDeck.append(tuple)
                }
            }
        }
        
        // done
        group.notify(queue: DispatchQueue.main) {
            completed(tips, onDeck, errors)
        }
    }
    
    //swiftlint:disable force_cast
    fileprivate func refresh() {
        // refresh tip cell
        if let indexPath = tipsCollectionView.indexPathsForSelectedItems?.first {
            let cell = tipsCollectionView.cellForItem(at: indexPath) as! TipCollectionViewCell
            cell.configure(withTip: tips[indexPath.row])
        }

        // refresh on deck cell
        if let indexPath = onDeckCollectionView.indexPathsForSelectedItems?.first {
            let cell = onDeckCollectionView.cellForItem(at: indexPath) as! OnDeckCollectionViewCell
            cell.configure(withProgram: onDeckPrograms[indexPath.row].program, unWachtedEpisodeCount: onDeckPrograms[indexPath.row].unwatchedEpisodeCount, andEpisode: onDeck[indexPath.row])
        }

        // get data
        getData() { [weak self] tips, onDeck, errors in
            guard let strongSelf = self else {
                return
            }
            
            // set initial background image?
            if strongSelf.backgroundImageView.image == nil, let firstTip = tips.first {
                let _ = firstTip.getImage(ofSize: strongSelf.backgroundImageView.frame.size) { image, _, _ in
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
    //swiftlint:enable force_cast
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
            case tipsCollectionView:
                return tips.count
            case onDeckCollectionView:
                return onDeck.count
            default:
                return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.HomeToEpisodeDetails.rawValue, sender: collectionView)
    }
    
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
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
        
        let _ = image?.getImage(ofSize: self.backgroundImageView.frame.size) { [weak self] image, _, _ in
            self?.backgroundImageView.image = image
        }
    }
    // swiftlint:enable force_cast
    
    // MARK: Tips
    
    //swiftlint:disable force_cast
    fileprivate func dequeueTipCell(forCollectionView collectionView: UICollectionView, andIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCells.Tip.rawValue, for: indexPath) as! TipCollectionViewCell
        cell.configure(withTip: self.tips[indexPath.row])
        return cell
    }
    //swiftlint:enable force_cast
    
    // MARK: On Deck
    
    //swiftlint:disable force_cast
    fileprivate func dequeueOnDeckCell(forCollectionView collectionView: UICollectionView, andIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCells.OnDeck.rawValue, for: indexPath) as! OnDeckCollectionViewCell
        let row = (indexPath as NSIndexPath).row
        
        if row >= 0 && row < onDeck.count {
            let episode = onDeck[row]
            let program = onDeckPrograms[row].program
            let count = onDeckPrograms[row].unwatchedEpisodeCount
            
            cell.configure(withProgram: program, unWachtedEpisodeCount: count, andEpisode: episode)
        }
        
        return cell
    }
    //swiftlint:enable force_cast

    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Segues.HomeToEpisodeDetails.rawValue, let collectionView = sender as? UICollectionView, let indexPath = collectionView.indexPathsForSelectedItems?.first, let vc = segue.destination as? EpisodeViewController else {
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
