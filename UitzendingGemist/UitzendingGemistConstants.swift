//
//  UitzendingGemistConstants.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 17/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation

enum CollectionViewCells: String {
    case Tip = "tipCollectionViewCell"
    case Still = "stillCollectionViewCell"
    case Program = "programCollectionViewCell"
    case Episode = "episodeCollectionViewCell"
    case Live = "liveCollectionViewCell"
    case ProgramDetail = "programDetailedCollectionViewCell"
}

enum TableViewCells: String {
    case ProgramGroup = "programRootTableViewCell"
}

enum CollectionViewHeaders: String {
    case Program = "programCollectionViewHeader"
}

enum ViewControllers: String {
    case ProgramViewController = "ProgramViewController"
}

enum Segues: String {
    case TipToEpisodeDetails = "TipToEpisodeDetailsSegue"
    case EpisodeToProgramDetails = "EpisodeToProgramDetailsSegue"
    case ProgramToDetails = "ProgramToProgramDetailsSegue"
    case ProgramToEpisode = "ProgramToEpisodeSegue"
    case ProgramToPlayEpisode = "ProgramToPlayEpisodeSegue"
}

public class UitzendingGemistConstants {
    static let unknownText = NSLocalizedString("Onbekend", comment: "Unkown")
    static let genreText = NSLocalizedString("Genre", comment: "Genre")
    static let broadcasterText = NSLocalizedString("Omroep", comment: "Broadcaster")
    
    static let playText = NSLocalizedString("Speel", comment: "Play")
    static let toProgramText = NSLocalizedString("Naar Programma", comment: "To Program")
    static let favoriteText = NSLocalizedString("Favoriet", comment: "Favorite")
    
    static let continueWatchingTitleText = NSLocalizedString("Verder kijken", comment: "Continue watching")
    static let continueWatchingMessageText = NSLocalizedString("U heeft deze aflevering al deels bekeken. Wilt u verder kijken vanaf het punt waar u bent gebleven of wilt u opnieuw beginnen?",
                                                               comment: "Ask user to continue watching or to restart")
    static let coninueWatchingFromText = NSLocalizedString("Verder kijken vanaf %@", comment: "Continue watching from hh:min:ss")
    static let watchFromStartText = NSLocalizedString("Bij het begin beginnen", comment: "Start watching from the beginning")
    
    static let cancelText = NSLocalizedString("Annuleren", comment: "Cancel")
    
    static let waitText = NSLocalizedString("Een ogenblik geduld alstublieft...", comment: "Please wait text")
    
    static let updateAvailableTitle = NSLocalizedString("Nieuwere versie beschikbaar", comment: "A newer version is available")
    static let updateAvailableText = NSLocalizedString("Uitzending Gemist versie '%@' is beschikbaar op %@ . Momenteel maakt u gebruik van Uitzending Gemist versie '%@'.", comment: "A newer version is available for download")
    static let okayButtonText = NSLocalizedString("OK", comment: "OK Button Text")
    
    static let commercials = NSLocalizedString("Reclame", comment: "Commercial break")
    static let currentBroadcast = NSLocalizedString("Nu: %@", comment: "Current broadcast")
    static let upcomingBroadcast = NSLocalizedString("Straks: %@", comment: "Upcoming broadcast (without time)")
    static let upcomingBroadcastWithTime = NSLocalizedString("%@: %@", comment: "Upcoming broadcast (with time)")
}
