//
//  ProgramViewController.swift
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

class ProgramViewController: UIViewController, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    private var programs = [NPOProgram]()
    private var filteredPrograms = [NPOProgram]() {
        didSet {
            self.programCollectionView.reloadData()
        }
    }
    
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
        var letters = [String]()
        
        switch item.tag {
            case 0:
                self.filteredPrograms = self.programs.filter { $0.favorite }
                return
            case 1:
                letters = ["#"]
                break
            case 2:
                letters = ["a", "b", "c", "d", "e"]
                break
            case 3:
                letters = ["f", "g", "h", "i", "j"]
                break
            case 4:
                letters = ["k", "l", "m", "n", "o"]
                break
            case 5:
                letters = ["p", "q", "r", "s", "t"]
                break
            case 6:
                letters = ["u", "v", "w", "x", "y", "z"]
                break
            default:
                return
        }
        
        self.filteredPrograms = self.programs.filter { letters.contains($0.firstLetter ?? "n/a") }
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredPrograms.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.Program.rawValue, forIndexPath: indexPath)
        
        guard let programCell = cell as? ProgramCollectionViewCell where indexPath.row >= 0 && indexPath.row < self.filteredPrograms.count else {
            return cell
        }
        
        let program = self.filteredPrograms[indexPath.row]
        programCell.configure(withProgram: program)
    
        return programCell
    }
    
    //MARK: UICollectionViewDelegate
    
    weak private var backgroundImageRequest: NPORequest?
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath where indexPath.row >= 0 && indexPath.row < self.filteredPrograms.count else {
            return
        }
        
        let program = self.filteredPrograms[indexPath.row]
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
