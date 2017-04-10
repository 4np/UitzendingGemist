//
//  UitzendingGemistConstants.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 17/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

enum CollectionViewCells: String {
    case tip = "tipCollectionViewCell"
    case onDeck = "onDeckCollectionViewCell"
    case still = "stillCollectionViewCell"
    case program = "programCollectionViewCell"
    case episode = "episodeCollectionViewCell"
    case live = "liveCollectionViewCell"
    case programDetail = "programDetailedCollectionViewCell"
    case dayDetail = "byDayDetailCollectionViewCell"
    case youTube = "youTubeCollectionViewCell"
}

enum TableViewCells: String {
    case programGroup = "programRootTableViewCell"
    case day = "byDayRootTableViewCell"
}

//enum CollectionViewHeaders: String {
//    case Episode = "episodeCollectionViewHeader"
//    case Program = "programCollectionViewHeader"
//}

enum ViewControllers: String {
    case programViewController = "ProgramViewController"
    case episodeViewController = "EpisodeViewController"
}

enum Segues: String {
    case homeToEpisodeDetails = "HomeToEpisodeDetailsSegue"
    case episodeToProgramDetails = "EpisodeToProgramDetailsSegue"
    case programToDetails = "ProgramToProgramDetailsSegue"
    case programToEpisode = "ProgramToEpisodeSegue"
    case programToPlayEpisode = "ProgramToPlayEpisodeSegue"
    case programToYouTube = "ProgramToYouTubeSegue"
}

open class UitzendingGemistConstants {
    // user defaults
    static let closedCaptioningEnabledKey = "UGClosedCaptioningEnabled"
    static let forceSecureTransportKey = "UGForceSecureTransport"
    
    // some unicode characters to use: ⦁◔◕◖◗◉●●⌾◕◔◖●⊚⊛⌾⍟⃘⃠•๏ං௦
    static let watchedSymbol = ""
    static let unwatchedSymbol = "● "
    static let partiallyWatchedSymbol = "๏ "
    static let favoriteSymbol = " ♥︎"
    static let separator = " · "
}
