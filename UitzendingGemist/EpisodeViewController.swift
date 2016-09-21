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
import UIColor_Hex_Swift

class EpisodeViewController: UIViewController {
    @IBOutlet weak fileprivate var backgroundImageView: UIImageView!
    @IBOutlet weak fileprivate var episodeImageView: UIImageView!
    @IBOutlet weak fileprivate var programNameLabel: UILabel!
    @IBOutlet weak fileprivate var episodeNameLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    @IBOutlet weak fileprivate var durationLabel: UILabel!
    @IBOutlet weak fileprivate var descriptionLabel: UILabel!
    @IBOutlet weak fileprivate var genreTitleLabel: UILabel!
    @IBOutlet weak fileprivate var genreLabel: UILabel!
    @IBOutlet weak fileprivate var broadcasterTitleLabel: UILabel!
    @IBOutlet weak fileprivate var broadcasterLabel: UILabel!
    @IBOutlet weak fileprivate var playButton: UIButton!
    @IBOutlet weak fileprivate var playLabel: UILabel!
    @IBOutlet weak fileprivate var toProgramButton: UIButton!
    @IBOutlet weak fileprivate var toProgramLabel: UILabel!
    @IBOutlet weak fileprivate var markAsWatchedButton: UIButton!
    @IBOutlet weak fileprivate var markAsWatchedLabel: UILabel!
    @IBOutlet weak fileprivate var favoriteButton: UIButton!
    @IBOutlet weak fileprivate var favoriteLabel: UILabel!
    @IBOutlet weak fileprivate var stillCollectionView: UICollectionView!

    fileprivate var tip: NPOTip?
    fileprivate var episode: NPOEpisode?
    fileprivate var program: NPOProgram?
    
    fileprivate var needLayout = false {
        didSet {
            if needLayout {
                layout()
            }
        }
    }

    // MARK: Calculated Properties
    
    fileprivate var programName: String? {
        if let program = self.program, let name = program.name, !name.isEmpty {
            return name
        } else if let program = episode?.program, let name = program.name, !name.isEmpty {
            return name
        } else if let name = tip?.name, !name.isEmpty {
            return name
        } else if let episode = self.episode, let name = episode.name, !name.isEmpty {
            return name
        }
        
        return nil
    }
    
    fileprivate var episodeName: String? {
        var episodeName = ""
        
        if let episode = self.episode, let name = episode.name, !name.isEmpty {
            episodeName = name
        } else if let name = tip?.name, !name.isEmpty {
            episodeName = name
        } else {
            episodeName = UitzendingGemistConstants.unknownEpisodeName
        }
        
        guard let programName = self.programName else {
            return episodeName
        }
        
        // replace program name
        episodeName = episodeName.replacingOccurrences(of: programName, with: "", options: .caseInsensitive, range: nil)
        
        // remove garbage from beginning of name
        if let regex = try? NSRegularExpression(pattern: "^([^a-z0-9]+)", options: .caseInsensitive) {
            let range = NSRange(0..<episodeName.utf16.count)
            episodeName = regex.stringByReplacingMatches(in: episodeName, options: .withTransparentBounds, range: range, withTemplate: "")
        }
        
        // got a name?
        if episodeName.characters.count == 0 {
            episodeName = programName
        }
        
        // capitalize
        episodeName = episodeName.capitalized
        
        // add watched indicator
        if let watchedIndicator = episode?.watchedIndicator {
            episodeName = watchedIndicator + episodeName
        }
        
        return episodeName
    }
    
    fileprivate var broadcastDisplayValue: String? {
        if let value = episode?.broadcastedDisplayValue {
            return value
        } else if let value = tip?.publishedDisplayValue {
            return value
        }
        
        return nil
    }
    
    fileprivate var episodeDescription: String? {
        if let description = tip?.description {
            return description
        } else if let description = episode?.description {
            return description
        }
        
        return nil
    }
    
    fileprivate var genres: String? {
        guard let genres = episode?.genres, genres.count > 0 else {
            return nil
        }
        
        return genres.map({ $0.rawValue }).joined(separator: "\n")
    }
    
    fileprivate var broadcasters: String? {
        guard let broadcasters = episode?.broadcasters, broadcasters.count > 0 else {
            return nil
        }

        return broadcasters.map({ $0.rawValue }).joined(separator: "\n")
    }
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to background image
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = backgroundImageView.bounds
        backgroundImageView.addSubview(visualEffectView)
        
        // clear out values
        backgroundImageView.image = nil
        
        episodeImageView.image = nil
        
        programNameLabel.text = nil
        episodeNameLabel.text = nil
        
        dateLabel.text = nil
        durationLabel.text = nil
        descriptionLabel.text = nil

        genreTitleLabel.text = nil
        genreLabel.text = nil
        broadcasterTitleLabel.text = nil
        broadcasterLabel.text = nil
        
        playButton.isEnabled = true
        playLabel.isEnabled = true
        playLabel.text = nil
        
        toProgramButton.isEnabled = true
        toProgramLabel.isEnabled = true
        toProgramLabel.text = nil
        
        markAsWatchedButton.isEnabled = true
        markAsWatchedLabel.isEnabled = true
        markAsWatchedLabel.text = nil
        
        favoriteButton.isEnabled = false
        favoriteLabel.isEnabled = false
        favoriteLabel.text = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // layout view
        layout()
    }
    
    // MARK: Configuration
    
    func configure(withTip tip: NPOTip) {
        self.tip = tip
        configure(withEpisode: tip.episode)
    }
    
    func configure(withEpisode episode: NPOEpisode?) {
        self.episode = episode
        getDetails(forEpisode: episode)
    }
    
    func configureAndPlay(withEpisode episode: NPOEpisode?) {
        getDetails(forEpisode: episode) { [weak self] in
            self?.play()
        }
    }
    
    // MARK: Networking
    
    fileprivate func getDetails(forEpisode episode: NPOEpisode?, withCompletion completed: @escaping () -> () = {}) {
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
            self?.getDetails(forProgram: episode.program, withCompletion: completed)
        }
    }
    
    fileprivate func getDetails(forProgram program: NPOProgram?, withCompletion completed: @escaping () -> () = {}) {
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
            completed()
        }
    }
    
    // MARK: Update UI
    
    fileprivate func layout() {
        guard needLayout else {
            return
        }
        
        // mark that we do not need layout anymore
        needLayout = false
        
        // layout images
        layoutImages()
        
        // layout labels
        programNameLabel.text = programName
        episodeNameLabel.text = episodeName
        
        dateLabel.text = broadcastDisplayValue?.capitalized
        durationLabel.text = episode?.duration.timeDisplayValue
        descriptionLabel.text = episodeDescription?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        genreTitleLabel.text = UitzendingGemistConstants.genreText.uppercased()
        genreLabel.text = genres ?? UitzendingGemistConstants.unknownText
        broadcasterTitleLabel.text = UitzendingGemistConstants.broadcasterText.uppercased()
        broadcasterLabel.text = broadcasters ?? UitzendingGemistConstants.unknownText
        
        playButton.isEnabled = true
        playLabel.isEnabled = true
        playLabel.text = UitzendingGemistConstants.playText
        
        toProgramButton.isEnabled = (program != nil)
        toProgramLabel.isEnabled = (program != nil)
        toProgramLabel.text = UitzendingGemistConstants.toProgramText
        
        markAsWatchedButton.isEnabled = true
        markAsWatchedLabel.isEnabled = true
        updateWatchedButtonAndLabel()
        
        favoriteButton.isEnabled = (program != nil)
        favoriteLabel.isEnabled = (program != nil)
        favoriteLabel.text = UitzendingGemistConstants.favoriteText
        updateFavoriteButtonTitleColor()
        
        stillCollectionView.reloadData()
    }
    
    fileprivate func updateFavoriteButtonTitleColor() {
        let color = program?.getUnfocusedColor() ?? UIColor.white
        let focusColor = program?.getFocusedColor() ?? UIColor.black
        favoriteButton.setTitleColor(color, for: .normal)
        favoriteButton.setTitleColor(focusColor, for: .focused)
    }
    
    fileprivate func updateWatchedButtonAndLabel() {
        guard let episode = self.episode else {
            return
        }
        
        if episode.watched == .unwatched || episode.watched == .partially {
            markAsWatchedLabel.text = UitzendingGemistConstants.markAsWatchedText
        } else {
            markAsWatchedLabel.text = UitzendingGemistConstants.markAsUnwatchedText
        }
        
        episodeNameLabel.text = episodeName
    }
    
    // MARK: Images
    
    fileprivate func layoutImages() {
        if let tip = self.tip {
            getImage(forTip: tip, andImageView: backgroundImageView)
            getImage(forTip: tip, andImageView: episodeImageView)
        } else if let episode = self.episode {
            getImage(forEpisode: episode, andImageView: backgroundImageView)
            getImage(forEpisode: episode, andImageView: episodeImageView)
        }
    }
    
    fileprivate func getImage(forTip tip: NPOTip, andImageView imageView: UIImageView) {
        tip.getImage(ofSize: imageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not get image for tip (\(error))")
                self?.getImage(forEpisode: tip.episode, andImageView: imageView)
                return
            }
            
            imageView.image = image
        }
    }
    
    fileprivate func getImage(forEpisode episode: NPOEpisode?, andImageView imageView: UIImageView) {
        guard let episode = episode else {
            return
        }
        
        episode.getImage(ofSize: imageView.frame.size) { [weak self] image, error, _ in
            guard let image = image else {
                DDLogError("Could not get image for episode (\(error))")
                self?.getImage(forProgram: episode.program, andImageView: imageView)
                return
            }
            
            imageView.image = image
        }
    }
    
    fileprivate func getImage(forProgram program: NPOProgram?, andImageView imageView: UIImageView) {
        guard let program = program else {
            return
        }
        
        program.getImage(ofSize: imageView.frame.size) { image, error, _ in
            guard let image = image else {
                DDLogError("Could not get image for program (\(error))")
                return
            }
            
            imageView.image = image
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episode?.stills?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCells.Still.rawValue, for: indexPath)
        
        guard let stillCell = cell as? StillCollectionViewCell, let stills = episode?.stills, indexPath.row >= 0 && indexPath.row < stills.count else {
            return cell
        }
        
        stillCell.configure(withStill: stills[indexPath.row])
        return stillCell
    }
    
    // MARK: Play
    
    @IBAction fileprivate func didPressPlayButton(_ sender: UIButton) {
        play()
    }
    
    // MARK: Player
    
    fileprivate func play() {
        guard let episode = self.episode else {
            DDLogError("Could not play episode...")
            return
        }
        
        // check if this episode has already been watched
        guard episode.watchDuration > 0 && episode.watched == .partially else {
            play(beginAt: 0)
            return
        }
        
        // show alert
        let alertController = UIAlertController(title: UitzendingGemistConstants.continueWatchingTitleText, message: UitzendingGemistConstants.continueWatchingMessageText, preferredStyle: .actionSheet)
        let coninueTitleText = String.localizedStringWithFormat(UitzendingGemistConstants.coninueWatchingFromText, episode.watchDuration.timeDisplayValue)
        let continueAction = UIAlertAction(title: coninueTitleText, style: .default) { [weak self] _ in
            self?.play(beginAt: episode.watchDuration)
        }
        alertController.addAction(continueAction)
        let fromBeginningAction = UIAlertAction(title: UitzendingGemistConstants.watchFromStartText, style: .default) { [weak self] _ in
            self?.play(beginAt: 0)
        }
        alertController.addAction(fromBeginningAction)
        let cancelAction = UIAlertAction(title: UitzendingGemistConstants.cancelText, style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func play(beginAt begin: Int) {
        guard let episode = self.episode else {
            DDLogError("Could not play episode...")
            return
        }
        
        // show progress hud
        view.startLoading()
    
        // play video stream
        episode.getVideoStream() { [weak self] url, error in
            self?.view.stopLoading()
            
            guard let url = url else {
                DDLogError("Could not play episode (\(error))")
                return
            }
            
            self?.play(episode: episode, withVideoStream: url, beginAt: begin)
        }
    }
    
    fileprivate func play(episode: NPOEpisode, withVideoStream url: URL, beginAt seconds: Int) {
        // set up player
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // (re)set play data
        episode.watchDuration = seconds
        
        // seek to start?
        if seconds > 0 {
            let seekTime = CMTimeMakeWithSeconds(Float64(seconds), 1)
            player.seek(to: seekTime, toleranceBefore: kCMTimePositiveInfinity, toleranceAfter: kCMTimeZero)
        }
        
        // reset playback time
        episode.watchDuration = seconds
        
        // observe player
        let interval = CMTimeMakeWithSeconds(1, 1) // 1 second
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let episode = self?.episode else {
                return
            }
            
            let seconds = Int(time.seconds)
            
            guard seconds > episode.watchDuration else {
                return
            }
            
            episode.watchDuration = seconds
        }
        
        // present player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    // MARK: Favorite
    
    @IBAction fileprivate func didPressFavoriteButton(_ sender: UIButton) {
        program?.toggleFavorite()
        updateFavoriteButtonTitleColor()
    }
    
    // MARK: Mark as watched
    
    @IBAction func didPressMarkAsWatchedButton(_ sender: UIButton) {
        episode?.toggleWatched()
        updateWatchedButtonAndLabel()
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }

        switch segueIdentifier {
            case Segues.EpisodeToProgramDetails.rawValue:
                prepareForSegueToProgramView(segue, sender: sender as AnyObject?)
                break
            default:
                DDLogError("Unhandled segue with identifier '\(segueIdentifier)' in Home view")
                break
        }
    }
    
    fileprivate func prepareForSegueToProgramView(_ segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destination as? ProgramViewController, let program = self.program else {
            return
        }
        
        vc.configure(withProgram: program)
    }
}
