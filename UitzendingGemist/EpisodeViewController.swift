//
//  EpisodeViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 16/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit
import CocoaLumberjack
import AVKit

class EpisodeViewController: UIViewController {
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var episodeImageView: UIImageView!
    @IBOutlet weak private var programNameLabel: UILabel!
    @IBOutlet weak private var episodeNameLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var durationLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var genreTitleLabel: UILabel!
    @IBOutlet weak private var genreLabel: UILabel!
    @IBOutlet weak private var broadcasterTitleLabel: UILabel!
    @IBOutlet weak private var broadcasterLabel: UILabel!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet weak private var playLabel: UILabel!
    @IBOutlet weak private var toProgramButton: UIButton!
    @IBOutlet weak private var toProgramLabel: UILabel!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var favoriteLabel: UILabel!
    
    private var tip: NPOTip?
    private var episode: NPOEpisode?
    private var program: NPOProgram?
    
    private var needLayout = false {
        didSet {
            if needLayout {
                self.layout()
            }
        }
    }
    
    //MARK: Calculated Properties
    
    private var programName: String? {
        if let name = self.program?.name where name.characters.count > 0 {
            return name
        } else if let name = self.episode?.program?.name where name.characters.count > 0 {
            return name
        } else if let name = self.tip?.name where name.characters.count > 0 {
            return name
        } else if let name = self.episode?.name where name.characters.count > 0 {
            return name
        }
        
        return nil
    }
    
    private var episodeName: String? {
        var episodeName = ""
        
        if let name = self.episode?.name where name.characters.count > 0 {
            episodeName = name
        } else if let name = self.tip?.name where name.characters.count > 0 {
            episodeName = name
        } else {
            return nil
        }
        
        guard let programName = self.programName else {
            return episodeName
        }
        
        // replace program name
        episodeName = episodeName.stringByReplacingOccurrencesOfString(programName, withString: "", options: .CaseInsensitiveSearch, range: nil)
        
        // remove garbage from beginning of name
        if let regex = try? NSRegularExpression(pattern: "^([^a-z0-9]+)", options: .CaseInsensitive) {
            let range = NSRange(0..<episodeName.utf16.count)
            episodeName = regex.stringByReplacingMatchesInString(episodeName, options: .WithTransparentBounds, range: range, withTemplate: "")
        }
        
        // got a name?
        if episodeName.characters.count == 0 {
            episodeName = programName
        }
        
        return episodeName.capitalizedString
    }
    
    private var broadcastDisplayValue: String? {
        if let value = self.episode?.broadcastedDisplayValue {
            return value
        } else if let value = self.tip?.publishedDisplayValue {
            return value
        }
        
        return nil
    }
    
    private var episodeDescription: String? {
        if let description = self.tip?.description {
            return description
        } else if let description = self.episode?.description {
            return description
        }
        
        return nil
    }
    
    private var genres: String? {
        guard let genres = self.episode?.genres where genres.count > 0 else {
            return nil
        }
        
        return genres.map({ $0.rawValue }).joinWithSeparator("\n")
    }
    
    private var broadcasters: String? {
        guard let broadcasters = self.episode?.broadcasters where broadcasters.count > 0 else {
            return nil
        }

        return broadcasters.map({ $0.rawValue }).joinWithSeparator("\n")
    }
    
    //MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        // add blur effect to background image
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = backgroundImageView.bounds
        backgroundImageView.addSubview(visualEffectView)
        
        // clear out values
        self.backgroundImageView.image = nil
        
        self.episodeImageView.image = nil
        
        self.programNameLabel.text = nil
        self.episodeNameLabel.text = nil
        
        self.dateLabel.text = nil
        self.durationLabel.text = nil
        self.descriptionLabel.text = nil

        self.genreTitleLabel.text = nil
        self.genreLabel.text = nil
        self.broadcasterTitleLabel.text = nil
        self.broadcasterLabel.text = nil
        
        self.playButton.enabled = true
        self.playLabel.enabled = true
        self.playLabel.text = nil
        
        self.toProgramButton.enabled = true
        self.toProgramLabel.enabled = true
        self.toProgramLabel.text = nil
        
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
    
    func configure(withTip tip: NPOTip) {
        self.tip = tip
        self.configure(withEpisode: tip.episode)
    }
    
    func configure(withEpisode episode: NPOEpisode?) {
        self.episode = episode
        self.getDetails(forEpisode: episode)
    }
    
    //MARK: Networking
    
    private func getDetails(forEpisode episode: NPOEpisode?) {
        guard let episode = episode else {
            return
        }
        
        // fetch episode details
        NPOManager.sharedInstance.getDetails(forEpisode: episode) { [weak self] episode, error in
            guard let episode = episode else {
                DDLogError("Could not fetch episode details (\(error))")
                self?.needLayout = true
                return
            }
            
            // update episode
            self?.episode = episode
            self?.getDetails(forProgram: episode.program)
        }
    }
    
    private func getDetails(forProgram program: NPOProgram?) {
        guard let program = program else {
            return
        }
        
        // fetch program details
        NPOManager.sharedInstance.getDetails(forProgram: program) { [weak self] program, error in
            guard let program = program else {
                DDLogError("Could not fetch program details (\(error))")
                self?.needLayout = true
                return
            }
            
            // update program
            self?.program = program
            self?.needLayout = true
        }
    }
    
    //MARK: Update UI
    
    private func layout() {
        guard self.needLayout else {
            return
        }
        
        // mark that we do not need layout anymore
        self.needLayout = false
        
        // layout images
        self.layoutImages()
        
        // layout labels
        self.programNameLabel.text = self.programName
        self.episodeNameLabel.text = self.episodeName
        
        self.dateLabel.text = self.broadcastDisplayValue?.capitalizedString
        self.durationLabel.text = self.episode?.durationDisplayValue
        self.descriptionLabel.text = self.episodeDescription?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        self.genreTitleLabel.text = UitzendingGemistConstants.genreText.uppercaseString
        self.genreLabel.text = self.genres ?? UitzendingGemistConstants.unknownText
        self.broadcasterTitleLabel.text = UitzendingGemistConstants.broadcasterText.uppercaseString
        self.broadcasterLabel.text = self.broadcasters ?? UitzendingGemistConstants.unknownText
        
        self.playButton.enabled = true
        self.playLabel.enabled = true
        self.playLabel.text = UitzendingGemistConstants.playText
        
        self.toProgramButton.enabled = (self.program != nil)
        self.toProgramLabel.enabled = (self.program != nil)
        self.toProgramLabel.text = UitzendingGemistConstants.toProgramText
        
        self.favoriteButton.enabled = false
        self.favoriteLabel.enabled = false
        self.favoriteLabel.text = UitzendingGemistConstants.favoriteText
    }
    
    //MARK: Images
    
    private func layoutImages() {
        if let tip = self.tip {
            self.getImage(forTip: tip, andImageView: self.backgroundImageView)
            self.getImage(forTip: tip, andImageView: self.episodeImageView)
        } else if let episode = self.episode {
            self.getImage(forEpisode: episode, andImageView: self.backgroundImageView)
            self.getImage(forEpisode: episode, andImageView: self.episodeImageView)
        }
    }
    
    private func getImage(forTip tip: NPOTip, andImageView imageView: UIImageView) {
        tip.getImage(ofSize: imageView.frame.size) { [weak self] image, error in
            guard let image = image else {
                DDLogError("Could not get image for tip (\(error))")
                self?.getImage(forEpisode: tip.episode, andImageView: imageView)
                return
            }
            
            imageView.image = image
        }
    }
    
    private func getImage(forEpisode episode: NPOEpisode?, andImageView imageView: UIImageView) {
        guard let episode = episode else {
            return
        }
        
        episode.getImage(ofSize: imageView.frame.size) { [weak self] image, error in
            guard let image = image else {
                DDLogError("Could not get image for episode (\(error))")
                self?.getImage(forProgram: episode.program, andImageView: imageView)
                return
            }
            
            imageView.image = image
        }
    }
    
    private func getImage(forProgram program: NPOProgram?, andImageView imageView: UIImageView) {
        guard let program = program else {
            return
        }
        
        program.getImage(ofSize: imageView.frame.size) { image, error in
            guard let image = image else {
                DDLogError("Could not get image for program (\(error))")
                return
            }
            
            imageView.image = image
        }
    }
    
    //MARK: Play
    
    @IBAction func didPressPlayButton(sender: UIButton) {
        self.episode?.getVideoStream() { [weak self] url, error in
            guard let url = url else {
                DDLogError("Coult not get video stream (\(error))")
                return
            }
        
            self?.playVideo(withURL: url)
        }
    }
    
    //MARK: Player
    
    private func playVideo(withURL url: NSURL) {
        // set up player
        let player = AVPlayer(URL: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        //        // (re)set play data
        //        episode.watchDuration = 0
        //
        //        // observe player
        //        let interval = CMTimeMakeWithSeconds(1, 1) // 1 second
        //        player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { time in
        //            let seconds = Int(time.seconds)
        //
        //            guard seconds > episode.watchDuration else {
        //                return
        //            }
        //
        //            episode.watchDuration = seconds
        //        }
        
        // present player
        self.presentViewController(playerViewController, animated: true) {
            DDLogDebug("playing video file from \(url.absoluteString)")
            
            playerViewController.player?.play()
        }
    }
}
