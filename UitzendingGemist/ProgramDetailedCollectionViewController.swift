//
//  ProgramDetailedCollectionViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 27/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack

class ProgramDetailedCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var programCollectionView: UICollectionView!
    
    fileprivate var programs = [NPOProgram]()
    
    // MARK: Configuration
    
    func configure(withPrograms programs: [NPOProgram]) {
        self.programs = programs
        programCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return programs.count
    }
    
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCells.ProgramDetail.rawValue, for: indexPath) as! ProgramDetailedCollectionViewCell
        cell.configure(withProgram: programs[indexPath.row])
        return cell
    }
    // swiftlint:enable force_cast
    
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let indexPath = context.nextFocusedIndexPath else {
                return
        }
        
        let program = programs[indexPath.row]
        let vc = self.splitViewController as! ProgramSplitViewController
        vc.configure(withProgram: program)
    }
    // swiftlint:enable force_cast
    
    // swiftlint:disable force_cast
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.splitViewController as! ProgramSplitViewController
        vc.didSelect(program: programs[indexPath.row])
    }
    // swiftlint:enable force_cast
}
