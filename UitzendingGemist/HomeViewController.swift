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
    @IBOutlet weak private var tipsCollectionView: UICollectionView!
    
    private var tips = [NPOTip]()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh tips
        self.getTips()
        
        // check for version update
        self.checkForUpdate()
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
    
    private func getTips() {
        // get tips
        NPOManager.sharedInstance.getTips() { [weak self] tips, error in
            guard let tips = tips else {
                DDLogError("Error fetching tips (\(error))")
                return
            }
            
            // set tips
            guard self?.tips.count > 0 else {
                self?.tips = tips
                self?.tipsCollectionView.reloadData()
                return
            }
            
            // update collection view
            self?.tipsCollectionView.performBatchUpdates({ 
                self?.updateCollectionView(withTips: tips)
            }, completion: { success in
                //DDLogDebug("finished updating tip collection: \(success)")
            })
        }
    }
    
    private func updateCollectionView(withTips tips: [NPOTip]) {
        // insert new tips
        let newTips = tips.filter({ !self.tips.contains($0) })
        let newIndexPaths = newTips.enumerate().map { NSIndexPath(forRow: $0.index, inSection: 0) }
        self.tips = newTips + self.tips
        self.tipsCollectionView.insertItemsAtIndexPaths(newIndexPaths)
        
        // remove old tips (in reverse order)
        let oldTips = self.tips.enumerate().filter({ !tips.contains($0.element) }).reverse()
        let oldIndexPaths = oldTips.map { NSIndexPath(forRow: $0.index, inSection: 0) }
        for oldTip in oldTips { self.tips.removeAtIndex(oldTip.index) }
        self.tipsCollectionView.deleteItemsAtIndexPaths(oldIndexPaths)
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tips.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.Tip.rawValue, forIndexPath: indexPath)
        
        guard let tipCell = cell as? TipCollectionViewCell else {
            return cell
        }
        
        tipCell.configure(withTip: self.tips[indexPath.row])
        return tipCell
    }

    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        switch segueIdentifier {
            case Segues.TipToEpisodeDetails.rawValue:
                prepareForSegueToEpisodeView(segue, sender: sender)
                break
            default:
                DDLogError("Unhandled segue with identifier '\(segueIdentifier)' in Home view")
                break
        }
    }
    
    private func prepareForSegueToEpisodeView(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? EpisodeViewController, cell = sender as? TipCollectionViewCell, indexPath = self.tipsCollectionView.indexPathForCell(cell) where indexPath.row >= 0 && indexPath.row < self.tips.count else {
            return
        }
        
        vc.configure(withTip: self.tips[indexPath.row])
    }
}
