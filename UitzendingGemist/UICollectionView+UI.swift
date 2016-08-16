//
//  UICollectionView+UI.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 16/08/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

extension UICollectionView {
    
    public func update(inout usingEpisodes episodes: [NPOEpisode], withNewEpisodes newEpisodes: [NPOEpisode]) {
        // first determine the old / removed episodes and remove them
        let old = episodes.enumerate().filter({ !newEpisodes.contains($0.element) }).reverse()
        let oldIndexPaths = old.map { NSIndexPath(forRow: $0.index, inSection: 0) }
        for oldEpisode in old {
            guard oldEpisode.index >= 0 && oldEpisode.index < episodes.count else {
                continue
            }
            
            episodes.removeAtIndex(oldEpisode.index)
        }
        deleteItemsAtIndexPaths(oldIndexPaths)
        
        // determine the new / added episodes and insert them
        let new = newEpisodes.enumerate().filter({ !episodes.contains($0.element) })
        let newIndexPaths = new.map { NSIndexPath(forRow: $0.index, inSection: 0) }
        for newEpisode in new {
            episodes.insert(newEpisode.element, atIndex: newEpisode.index)
        }
        insertItemsAtIndexPaths(newIndexPaths)
        
        // and re-order what needs to be
        let reverseEpisodes = newEpisodes.enumerate().reverse()
        for newEpisode in reverseEpisodes {
            guard let index = episodes.indexOf(newEpisode.element) where index != newEpisode.index else {
                continue
            }
            
            let from = NSIndexPath(forRow: index, inSection: 0)
            let to = NSIndexPath(forRow: newEpisode.index, inSection: 0)
            moveItemAtIndexPath(from, toIndexPath: to)
            //DDLogDebug("\(newEpisode.element.name ?? "?"): \(index) -> \(newEpisode.index)")
        }
    }
    
    public func update(inout usingTips tips: [NPOTip], withNewTips newTips: [NPOTip]) {
        // first determine the old / removed episodes and remove them
        let old = tips.enumerate().filter({ !newTips.contains($0.element) }).reverse()
        let oldIndexPaths = old.map { NSIndexPath(forRow: $0.index, inSection: 0) }
        for oldEpisode in old {
            guard oldEpisode.index >= 0 && oldEpisode.index < tips.count else {
                continue
            }
            
            tips.removeAtIndex(oldEpisode.index)
        }
        deleteItemsAtIndexPaths(oldIndexPaths)
        
        // determine the new / added episodes and insert them
        let new = newTips.enumerate().filter({ !tips.contains($0.element) })
        let newIndexPaths = new.map { NSIndexPath(forRow: $0.index, inSection: 0) }
        for newEpisode in new {
            tips.insert(newEpisode.element, atIndex: newEpisode.index)
        }
        insertItemsAtIndexPaths(newIndexPaths)
        
        // and re-order what needs to be
        let reverseTips = newTips.enumerate().reverse()
        for newTip in reverseTips {
            guard let index = tips.indexOf(newTip.element) where index != newTip.index else {
                continue
            }
            
            let from = NSIndexPath(forRow: index, inSection: 0)
            let to = NSIndexPath(forRow: newTip.index, inSection: 0)
            moveItemAtIndexPath(from, toIndexPath: to)
        }
    }
}
