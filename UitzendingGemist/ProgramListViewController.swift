//
//  ProgramListViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 18/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack
import AVKit

class ProgramListViewController: UIViewController, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    private var programs = [NPOProgram]() {
        didSet {
            self.programCollectionView.reloadData()
        }
    }
    
    private var filteredPrograms = [NPOProgram]() {
        didSet {
            self.programCollectionView.reloadData()
        }
    }
    
    // swiftlint:disable force_unwrapping
    private var uniqueLetters: [String] {
        get {
            let firstLetters = self.filteredPrograms.filter({ $0.firstLetter != nil }).map({ $0.firstLetter! })
            return Array(Set(firstLetters)).sort()
        }
    }
    // swiftlint:enable force_unwrapping
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var programCollectionView: UICollectionView!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to background image
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = backgroundImageView.bounds
        backgroundImageView.addSubview(visualEffectView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh programs
        self.getPrograms()
    }
    
    //MARK: Networking
    
    private func getPrograms() {
        NPOManager.sharedInstance.getPrograms { [weak self] programs, error in
            guard let programs = programs else {
                DDLogError("Could not get programs (\(error))")
                return
            }
            
            self?.programs = programs
            
            if let program = programs.first {
                self?.loadBackgroundImage(forProgram: program)
            }
        }
    }
    
    //MARK: UITabBarDelegate
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        guard item != tabBar.selectedItem else {
            return
        }
        
        var letters = [String]()
        
        switch item.tag {
            case 0:
                self.filteredPrograms = self.programs.filter { $0.favorite }
                return
            case 1:
                letters = ["#", "a", "b", "c", "d", "e"]
                break
            case 2:
                letters = ["f", "g", "h", "i", "j"]
                break
            case 3:
                letters = ["k", "l", "m", "n", "o"]
                break
            case 4:
                letters = ["p", "q", "r", "s", "t"]
                break
            case 5:
                letters = ["u", "v", "w", "x", "y", "z"]
                break
            default:
                return
        }
        
        self.filteredPrograms = self.programs.filter { letters.contains($0.firstLetter ?? "n/a") }
    }
    
    //MARK: Programs for section
    
    private func programs(forSection section: Int) -> [NPOProgram]? {
        let uniqueLetters = self.uniqueLetters
        
        guard section >= 0 && section < uniqueLetters.count else {
            return nil
        }

        let letter = uniqueLetters[section]
        return self.filteredPrograms.filter { $0.firstLetter == letter }
    }
    
    //MARK: UICollectionViewDataSource

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.uniqueLetters.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let letter = self.uniqueLetters[section]
        let programs = self.filteredPrograms.filter({ $0.firstLetter == letter })
        return programs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.Program.rawValue, forIndexPath: indexPath)

        guard let programCell = cell as? ProgramListCollectionViewCell, programsForSection = self.programs(forSection: indexPath.section)
            where indexPath.row >= 0 && indexPath.row < programsForSection.count else {
            return cell
        }
        
        programCell.configure(withProgram: programsForSection[indexPath.row])
        return programCell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: CollectionViewHeaders.Program.rawValue, forIndexPath: indexPath)
        let uniqueLetters = self.uniqueLetters
        
        guard let headerView = view as? ProgramListSectionHeaderView where indexPath.section >= 0 && indexPath.section < uniqueLetters.count else {
            return view
        }
        
        headerView.configure(withText: uniqueLetters[indexPath.section])
        return headerView
    }
    
    //MARK: UICollectionViewDelegate
    
    weak private var backgroundImageRequest: NPORequest?
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath, programsForSection = self.programs(forSection: indexPath.section)
            where indexPath.row >= 0 && indexPath.row < programsForSection.count else {
                return
        }
        
        let program = programsForSection[indexPath.row]
        self.loadBackgroundImage(forProgram: program)
    }
    
    private func loadBackgroundImage(forProgram program: NPOProgram) {
        self.backgroundImageRequest = program.getImage() { [weak self] image, error, request in
            guard let image = image where self?.backgroundImageRequest == request else {
                return
            }
            
            self?.backgroundImageView.image = image
        }
    }
}
