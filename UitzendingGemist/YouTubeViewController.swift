//
//  YouTubeViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 18/11/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import NPOKit
import CocoaLumberjack
import AVKit

class YouTubeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    fileprivate var program: NPOProgram?
    fileprivate var videos: [NPOYouTubeVideo]? {
        didSet {
            videoCollectionView.reloadData()
        }
    }

    // MARK: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = program?.name
    }
    
    // MARK: Configuration
    
    func configure(withProgram program: NPOProgram) {
        self.program = program
        
        NPOManager.sharedInstance.getYouTubeVideos(forProgram: program) { [weak self] videos, error in
            guard let videos = videos else {
                DDLogError("Could not fetch youtube videos for program \(program.name)")
                return
            }
            
            self?.videos = videos
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCells.YouTube.rawValue, for: indexPath)
        
        guard let youTubeCell = cell as? YouTubeCollectionViewCell, let videos = self.videos, indexPath.row >= 0 && indexPath.row < videos.count else {
            return cell
        }
        
        youTubeCell.configure(withYouTubeVideo: videos[indexPath.row])
        
        return youTubeCell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let videos = self.videos, let indexPath = context.nextFocusedIndexPath else {
            return
        }

        let video = videos[indexPath.row]
        
        // get image
        let _ = NPOManager.sharedInstance.getImage(forYouTubeVideo: video, ofSize: self.backgroundImageView.frame.size) { [weak self] image, _ in
            guard let image = image else {
                return
            }
            
            self?.backgroundImageView.image = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let videos = self.videos, indexPath.row >= 0 && indexPath.row < videos.count, let videoIdentifier = videos[indexPath.row].identifier?.videoId else {
            return
        }
        
        play(youtubeVideoWithIdentifier: videoIdentifier)
    }
    
    // MARK: Play YouTube video
    
    fileprivate func play(youtubeVideoWithIdentifier videoIdentifier: String) {
        let alert = getAlertController(show: true)
        
        // play video
        NPOManager.sharedInstance.getPlayerItem(youtubeVideoIdentifier: videoIdentifier) { [weak self] playerItem, error in
            // dismiss alert
            alert.dismiss(animated: false) {
                // set up player
                let player = AVPlayer(playerItem: playerItem)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                // when the player reached the end of the video, pause the video
                player.actionAtItemEnd = .pause
                
                // present player
                self?.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        }
    }
    
    fileprivate func getAlertController(show: Bool) -> UIAlertController {
        // create alert controller with a spinner on it
        let alertController = UIAlertController(title: "Een ogenblik geduld a.u.b.", message: "", preferredStyle: .alert)
        let bounds = alertController.view.bounds
        
        // create an activity indicator (spinner)
        let spinner = UIActivityIndicatorView(frame: bounds)
        spinner.center = CGPoint(x: bounds.midX, y: bounds.midY + 50.0)
        spinner.activityIndicatorViewStyle = .whiteLarge
        spinner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        spinner.isUserInteractionEnabled = false
        spinner.startAnimating()
        
        // add the activity indicator to the alert controller
        alertController.view.addSubview(spinner)
        
        // show it already?
        if show {
            self.present(alertController, animated: true, completion: nil)
        }
        
        // return it so we can dismiss it later
        return alertController
    }
}
