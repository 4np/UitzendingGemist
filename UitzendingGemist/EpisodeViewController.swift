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
    @IBOutlet weak private var markAsWatchedButton: UIButton!
    @IBOutlet weak private var markAsWatchedLabel: UILabel!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var favoriteLabel: UILabel!
    @IBOutlet weak private var stillCollectionView: UICollectionView!

    private var tip: NPOTip?
    private var episode: NPOEpisode?
    private var program: NPOProgram?
    
    private var needLayout = false {
        didSet {
            if needLayout {
                layout()
            }
        }
    }

    //MARK: Calculated Properties
    
    private var programName: String? {
        if let program = self.program, name = program.name where !name.isEmpty {
            return name
        } else if let program = episode?.program, name = program.name where !name.isEmpty {
            return name
        } else if let name = tip?.name where !name.isEmpty {
            return name
        } else if let episode = self.episode, name = episode.name where !name.isEmpty {
            return name
        }
        
        return nil
    }
    
    private var episodeName: String? {
        var episodeName = ""
        
        if let episode = self.episode, name = episode.name where !name.isEmpty {
            episodeName = name
        } else if let name = tip?.name where !name.isEmpty {
            episodeName = name
        } else {
            episodeName = UitzendingGemistConstants.unknownEpisodeName
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
        
        // capitalize
        episodeName = episodeName.capitalizedString
        
        // add watched indicator
        if let watchedIndicator = episode?.watchedIndicator {
            episodeName = watchedIndicator + episodeName
        }
        
        return episodeName
    }
    
    private var broadcastDisplayValue: String? {
        if let value = episode?.broadcastedDisplayValue {
            return value
        } else if let value = tip?.publishedDisplayValue {
            return value
        }
        
        return nil
    }
    
    private var episodeDescription: String? {
        if let description = tip?.description {
            return description
        } else if let description = episode?.description {
            return description
        }
        
        return nil
    }
    
    private var genres: String? {
        guard let genres = episode?.genres where genres.count > 0 else {
            return nil
        }
        
        return genres.map({ $0.rawValue }).joinWithSeparator("\n")
    }
    
    private var broadcasters: String? {
        guard let broadcasters = episode?.broadcasters where broadcasters.count > 0 else {
            return nil
        }

        return broadcasters.map({ $0.rawValue }).joinWithSeparator("\n")
    }
    
    //MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to background image
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
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
        
        playButton.enabled = true
        playLabel.enabled = true
        playLabel.text = nil
        
        toProgramButton.enabled = true
        toProgramLabel.enabled = true
        toProgramLabel.text = nil
        
        markAsWatchedButton.enabled = true
        markAsWatchedLabel.enabled = true
        markAsWatchedLabel.text = nil
        
        favoriteButton.enabled = false
        favoriteLabel.enabled = false
        favoriteLabel.text = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // layout view
        layout()
    }
    
    //MARK: Configuration
    
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
    
    //MARK: Networking
    
    private func getDetails(forEpisode episode: NPOEpisode?, withCompletion completed: () -> () = {}) {
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
    
    private func getDetails(forProgram program: NPOProgram?, withCompletion completed: () -> () = {}) {
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
    
    //MARK: Update UI
    
    private func layout() {
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
        
        dateLabel.text = broadcastDisplayValue?.capitalizedString
        durationLabel.text = episode?.duration.timeDisplayValue
        descriptionLabel.text = episodeDescription?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        genreTitleLabel.text = UitzendingGemistConstants.genreText.uppercaseString
        genreLabel.text = genres ?? UitzendingGemistConstants.unknownText
        broadcasterTitleLabel.text = UitzendingGemistConstants.broadcasterText.uppercaseString
        broadcasterLabel.text = broadcasters ?? UitzendingGemistConstants.unknownText
        
        playButton.enabled = true
        playLabel.enabled = true
        playLabel.text = UitzendingGemistConstants.playText
        
        toProgramButton.enabled = (program != nil)
        toProgramLabel.enabled = (program != nil)
        toProgramLabel.text = UitzendingGemistConstants.toProgramText
        
        markAsWatchedButton.enabled = true
        markAsWatchedLabel.enabled = true
        updateWatchedButtonAndLabel()
        
        favoriteButton.enabled = (program != nil)
        favoriteLabel.enabled = (program != nil)
        favoriteLabel.text = UitzendingGemistConstants.favoriteText
        updateFavoriteButtonTitleColor()
        
        stillCollectionView.reloadData()
    }
    
    private func updateFavoriteButtonTitleColor() {
        let color = program?.getUnfocusedColor() ?? UIColor.whiteColor()
        let focusColor = program?.getFocusedColor() ?? UIColor.blackColor()
        favoriteButton.setTitleColor(color, forState: .Normal)
        favoriteButton.setTitleColor(focusColor, forState: .Focused)
    }
    
    private func updateWatchedButtonAndLabel() {
        guard let episode = self.episode else {
            return
        }
        
        if episode.watched == .Unwatched || episode.watched == .Partially {
            markAsWatchedLabel.text = UitzendingGemistConstants.markAsWatchedText
        } else {
            markAsWatchedLabel.text = UitzendingGemistConstants.markAsUnwatchedText
        }
        
        episodeNameLabel.text = episodeName
    }
    
    //MARK: Images
    
    private func layoutImages() {
        if let tip = self.tip {
            getImage(forTip: tip, andImageView: backgroundImageView)
            getImage(forTip: tip, andImageView: episodeImageView)
        } else if let episode = self.episode {
            getImage(forEpisode: episode, andImageView: backgroundImageView)
            getImage(forEpisode: episode, andImageView: episodeImageView)
        }
    }
    
    private func getImage(forTip tip: NPOTip, andImageView imageView: UIImageView) {
        tip.getImage(ofSize: imageView.frame.size) { [weak self] image, error, _ in
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
        
        episode.getImage(ofSize: imageView.frame.size) { [weak self] image, error, _ in
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
        
        program.getImage(ofSize: imageView.frame.size) { image, error, _ in
            guard let image = image else {
                DDLogError("Could not get image for program (\(error))")
                return
            }
            
            imageView.image = image
        }
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episode?.stills?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCells.Still.rawValue, forIndexPath: indexPath)
        
        guard let stillCell = cell as? StillCollectionViewCell, stills = episode?.stills where indexPath.row >= 0 && indexPath.row < stills.count else {
            return cell
        }
        
        stillCell.configure(withStill: stills[indexPath.row])
        return stillCell
    }
    
    //MARK: Play
    
    @IBAction private func didPressPlayButton(sender: UIButton) {
        play()
    }
    
    //MARK: Player
    
    private func play() {
        guard let episode = self.episode else {
            DDLogError("Could not play episode...")
            return
        }
        
        // check if this episode has already been watched
        guard let watchDuration = episode.watchDuration where episode.watched == .Partially else {
            play(beginAt: 0)
            return
        }
        
        // show alert
        let alertController = UIAlertController(title: UitzendingGemistConstants.continueWatchingTitleText, message: UitzendingGemistConstants.continueWatchingMessageText, preferredStyle: .ActionSheet)
        let coninueTitleText = String.localizedStringWithFormat(UitzendingGemistConstants.coninueWatchingFromText, watchDuration.timeDisplayValue)
        let continueAction = UIAlertAction(title: coninueTitleText, style: .Default) { [weak self] _ in
            self?.play(beginAt: watchDuration)
        }
        alertController.addAction(continueAction)
        let fromBeginningAction = UIAlertAction(title: UitzendingGemistConstants.watchFromStartText, style: .Default) { [weak self] _ in
            self?.play(beginAt: 0)
        }
        alertController.addAction(fromBeginningAction)
        let cancelAction = UIAlertAction(title: UitzendingGemistConstants.cancelText, style: .Cancel) { _ in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func play(beginAt begin: Int) {
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
    
    private func play(episode episode: NPOEpisode, withVideoStream url: NSURL, beginAt seconds: Int) {
        // set up player
        let player = AVPlayer(URL: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        // (re)set play data
        episode.watchDuration = seconds
        
        // seek to start?
        if seconds > 0 {
            let seekTime = CMTimeMakeWithSeconds(Float64(seconds), 1)
            player.seekToTime(seekTime, toleranceBefore: kCMTimePositiveInfinity, toleranceAfter: kCMTimeZero)
        }
        
        // reset playback time
        episode.watchDuration = seconds
        
        // observe player
        let interval = CMTimeMakeWithSeconds(1, 1) // 1 second
        player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) { [weak self] time in
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
        presentViewController(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    //MARK: Favorite
    
    @IBAction private func didPressFavoriteButton(sender: UIButton) {
        program?.toggleFavorite()
        updateFavoriteButtonTitleColor()
    }
    
    //MARK: Mark as watched
    
    @IBAction func didPressMarkAsWatchedButton(sender: UIButton) {
        episode?.toggleWatched()
        updateWatchedButtonAndLabel()
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }

        switch segueIdentifier {
            case Segues.EpisodeToProgramDetails.rawValue:
                prepareForSegueToProgramView(segue, sender: sender)
                break
            default:
                DDLogError("Unhandled segue with identifier '\(segueIdentifier)' in Home view")
                break
        }
    }
    
    private func prepareForSegueToProgramView(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc = segue.destinationViewController as? ProgramViewController, program = self.program else {
            return
        }
        
        vc.configure(withProgram: program)
    }
}
