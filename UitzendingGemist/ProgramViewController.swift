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
    
    fileprivate var program: NPOProgram?
    
    fileprivate var needLayout = false {
        didSet {
            if needLayout {
                self.layout()
            }
        }
    }
    
    fileprivate var genres: String? {
        guard let genres = self.program?.genres, genres.count > 0 else {
            return nil
        }
        
        return genres.map({ $0.rawValue }).joined(separator: "\n")
    }
    
    fileprivate var broadcasters: String? {
        guard let broadcasters = self.program?.broadcasters, broadcasters.count > 0 else {
            return nil
        }
        
        return broadcasters.map({ $0.rawValue }).joined(separator: "\n")
    }
    
    fileprivate var episodes: [NPOEpisode]? {
        guard let episodes = self.program?.episodes else {
            return nil
        }
        
        return episodes.sorted {
            if let date0 = $0.broadcasted, let date1 = $1.broadcasted, date0.compare(date1) == .orderedDescending {
                return true
            } else {
                return false
            }
        }
    }
    
    fileprivate var unwatchedEpisodes: [NPOEpisode]? {
        return self.episodes?.filter({ $0.watched != .fully })
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to background image
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
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
        
        self.playButton.isEnabled = true
        self.playLabel.isEnabled = true
        self.playLabel.text = nil
        
        self.favoriteButton.isEnabled = false
        self.favoriteLabel.isEnabled = false
        self.favoriteLabel.text = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // layout view
        self.layout()
    }
    
    // MARK: Configuration
    
    func configure(withProgram program: NPOProgram) {
        let _ = NPOManager.sharedInstance.getDetails(forProgram: program) { [weak self] program, error in
            guard let program = program else {
                DDLogError("Could not fetch program (\(error))")
                return
            }
            
            self?.program = program
            self?.needLayout = true
        }
    }
    
    // MARK: Layout
    
    fileprivate func layout() {
        guard let program = self.program, self.needLayout else {
            return
        }
        
        // mark that we do not need layout anymore
        self.needLayout = false
        
        self.programNameLabel.text = program.getDisplayNameWithWatchedIndicator()
        self.descriptionLabel.text = program.description
        
        self.genreTitleLabel.text = UitzendingGemistConstants.genreText.uppercased()
        self.genreLabel.text = self.genres ?? UitzendingGemistConstants.unknownText
        self.broadcasterTitleLabel.text = UitzendingGemistConstants.broadcasterText.uppercased()
        self.broadcasterLabel.text = self.broadcasters ?? UitzendingGemistConstants.unknownText
        
        let unwatchedEpisodesCount = self.unwatchedEpisodes?.count ?? 0
        self.playButton.isEnabled = (unwatchedEpisodesCount > 0)
        self.playLabel.isEnabled = (unwatchedEpisodesCount > 0)
        self.playLabel.text = UitzendingGemistConstants.playText
        
        self.favoriteButton.isEnabled = (self.program != nil)
        self.favoriteLabel.isEnabled = (self.program != nil)
        self.favoriteLabel.text = UitzendingGemistConstants.favoriteText
        self.updateFavoriteButtonTitleColor()
        
        // fetch images
        self.layoutImages(forProgram: program)
        
        // layout episodes
        self.episodeCollectionView.reloadData()
    }
    
    fileprivate func updateFavoriteButtonTitleColor() {
        let isFavorite = self.program?.favorite ?? false
        let favoriteColor = UIColor.waxFlower
        let color = isFavorite ? favoriteColor : UIColor.white
        let focusColor = isFavorite ? favoriteColor : UIColor.black
        self.favoriteButton.setTitleColor(color, for: .normal)
        self.favoriteButton.setTitleColor(focusColor, for: .focused)
    }
    
    fileprivate func layoutImages(forProgram program: NPOProgram) {
        // background image
        let _ = program.getImage(ofSize: self.backgroundImageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not fetch image for program (\(error))")
                return
            }
            
            self?.backgroundImageView.image = image
        }
        
        // program image
        let _ = program.getImage(ofSize: self.programImageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not fetch image for program (\(error))")
                return
            }
            
            self?.programImageView.image = image
        }
    }
    
    // MARK: Favorite
    
    @IBAction fileprivate func didPressFavoriteButton(_ sender: UIButton) {
        self.program?.toggleFavorite()
        self.updateFavoriteButtonTitleColor()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.episodes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCells.Episode.rawValue, for: indexPath)
        
        guard let episodeCell = cell as? EpisodeCollectionViewCell, let episodes = self.episodes, indexPath.row >= 0 && indexPath.row < episodes.count else {
            return cell
        }
        
        episodeCell.configure(withEpisode: episodes[indexPath.row], andProgram: self.program)
        return episodeCell
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        
        switch segueIdentifier {
            case Segues.ProgramToEpisode.rawValue:
                prepareForSegueToEpisodeView(segue, sender: sender as AnyObject?)
                break
            case Segues.ProgramToPlayEpisode.rawValue:
                prepareForSegueToPlayEpisodeView(segue, sender: sender as AnyObject?)
                break
            default:
                DDLogError("Unhandled segue with identifier '\(segueIdentifier)' in Home view")
                break
        }
    }
    
    fileprivate func prepareForSegueToEpisodeView(_ segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destination as? EpisodeViewController, let cell = sender as? EpisodeCollectionViewCell, let indexPath = self.episodeCollectionView.indexPath(for: cell), let episodes = self.episodes, indexPath.row >= 0 && indexPath.row < episodes.count else {
            return
        }
        
        let episode = episodes[indexPath.row]
        vc.configure(withEpisode: episode)
    }

    fileprivate func prepareForSegueToPlayEpisodeView(_ segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destination as? EpisodeViewController, let episode = self.unwatchedEpisodes?.first else {
            return
        }
        
        vc.configureAndPlay(withEpisode: episode)
    }
}
