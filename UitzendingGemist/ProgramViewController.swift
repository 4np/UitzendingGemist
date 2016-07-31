//
//  ProgramViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 19/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack
import AVKit
import UIColor_Hex_Swift

class ProgramViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var programImageView: UIImageView!
    @IBOutlet weak var programNameLabel: UILabel!
    @IBOutlet weak var genreTitleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var broadcasterTitleLabel: UILabel!
    @IBOutlet weak var broadcasterLabel: UILabel!
    
    @IBOutlet weak var descriptionScrollView: AutoScrollView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var episodeCollectionView: UICollectionView!
    
    private var program: NPOProgram?
    
    private var needLayout = false {
        didSet {
            if needLayout {
                self.layout()
            }
        }
    }
    
    private var genres: String? {
        guard let genres = self.program?.genres where genres.count > 0 else {
            return nil
        }
        
        return genres.map({ $0.rawValue }).joinWithSeparator("\n")
    }
    
    private var broadcasters: String? {
        guard let broadcasters = self.program?.broadcasters where broadcasters.count > 0 else {
            return nil
        }
        
        return broadcasters.map({ $0.rawValue }).joinWithSeparator("\n")
    }
    
    private var episodes: [NPOEpisode]? {
        guard let episodes = self.program?.episodes else {
            return nil
        }
        
        return episodes.sort {
            if let date0 = $0.broadcasted, date1 = $1.broadcasted where date0.compare(date1) == .OrderedDescending {
                return true
            } else {
                return false
            }
        }
    }
    
    private var unwatchedEpisodes: [NPOEpisode]? {
        return self.episodes?.filter({ !$0.watched})
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to background image
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = backgroundImageView.bounds
        self.backgroundImageView.addSubview(visualEffectView)
        
        // clear out values
        self.backgroundImageView.image = nil
        
        self.programImageView.image = nil
        
        self.programNameLabel.text = nil

        self.descriptionLabel.text = nil
        
        self.genreTitleLabel.text = nil
        self.genreLabel.text = nil
        self.broadcasterTitleLabel.text = nil
        self.broadcasterLabel.text = nil
        
        self.playButton.enabled = true
        self.playLabel.enabled = true
        self.playLabel.text = nil
        
        self.favoriteButton.enabled = false
        self.favoriteLabel.enabled = false
        self.favoriteLabel.text = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // layout view
        self.layout()
    }
    
    //MARK: Configuration
    
    func configure(withProgram program: NPOProgram) {
        NPOManager.sharedInstance.getDetails(forProgram: program) { [weak self] program, error in
            guard let program = program else {
                DDLogError("Could not fetch program (\(error))")
                return
            }
            
            self?.program = program
            self?.needLayout = true
        }
    }
    
    //MARK: Layout
    
    private func layout() {
        guard let program = self.program where self.needLayout else {
            return
        }
        
        // mark that we do not need layout anymore
        self.needLayout = false
        
        self.programNameLabel.text = program.getDisplayNameWithWatchedIndicator()
        self.descriptionLabel.text = program.description
        
        self.genreTitleLabel.text = UitzendingGemistConstants.genreText.uppercaseString
        self.genreLabel.text = self.genres ?? UitzendingGemistConstants.unknownText
        self.broadcasterTitleLabel.text = UitzendingGemistConstants.broadcasterText.uppercaseString
        self.broadcasterLabel.text = self.broadcasters ?? UitzendingGemistConstants.unknownText
        
        self.playButton.enabled = (self.unwatchedEpisodes?.count > 0)
        self.playLabel.enabled = (self.unwatchedEpisodes?.count > 0)
        self.playLabel.text = UitzendingGemistConstants.playText
        
        self.favoriteButton.enabled = (self.program != nil)
        self.favoriteLabel.enabled = (self.program != nil)
        self.favoriteLabel.text = UitzendingGemistConstants.favoriteText
        self.updateFavoriteButtonTitleColor()
        
        // fetch images
        self.layoutImages(forProgram: program)
        
        // layout episodes
        self.episodeCollectionView.reloadData()
    }
    
    private func updateFavoriteButtonTitleColor() {
        let isFavorite = self.program?.favorite ?? false
        let favoriteColor = UIColor.waxFlower
        let color = isFavorite ? favoriteColor : UIColor.whiteColor()
        let focusColor = isFavorite ? favoriteColor : UIColor.blackColor()
        self.favoriteButton.setTitleColor(color, forState: .Normal)
        self.favoriteButton.setTitleColor(focusColor, forState: .Focused)
    }
    
    private func layoutImages(forProgram program: NPOProgram) {
        // background image
        program.getImage(ofSize: self.backgroundImageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not fetch image for program (\(error))")
                return
            }
            
            self?.backgroundImageView.image = image
        }
        
        // program image
        program.getImage(ofSize: self.programImageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not fetch image for program (\(error))")
                return
            }
            
            self?.programImageView.image = image
        }
    }
    
    //MARK: Favorite
    
    @IBAction private func didPressFavoriteButton(sender: UIButton) {
        self.program?.toggleFavorite()
        self.updateFavoriteButtonTitleColor()
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.episodes?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.Episode.rawValue, forIndexPath: indexPath)
        
        guard let episodeCell = cell as? EpisodeCollectionViewCell, episodes = self.episodes where indexPath.row >= 0 && indexPath.row < episodes.count else {
            return cell
        }
        
        episodeCell.configure(withEpisode: episodes[indexPath.row], andProgram: self.program)
        return episodeCell
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        switch segueIdentifier {
            case Segues.ProgramToEpisode.rawValue:
                prepareForSegueToEpisodeView(segue, sender: sender)
                break
            case Segues.ProgramToPlayEpisode.rawValue:
                prepareForSegueToPlayEpisodeView(segue, sender: sender)
                break
            default:
                DDLogError("Unhandled segue with identifier '\(segueIdentifier)' in Home view")
                break
        }
    }
    
    private func prepareForSegueToEpisodeView(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? EpisodeViewController, cell = sender as? EpisodeCollectionViewCell, indexPath = self.episodeCollectionView.indexPathForCell(cell), episodes = self.episodes where indexPath.row >= 0 && indexPath.row < episodes.count else {
            return
        }
        
        let episode = episodes[indexPath.row]
        vc.configure(withEpisode: episode)
    }

    private func prepareForSegueToPlayEpisodeView(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? EpisodeViewController, episode = self.unwatchedEpisodes?.first else {
            return
        }
        
        vc.configureAndPlay(withEpisode: episode)
    }
}
