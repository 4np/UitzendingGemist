//
//  String+i18n.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 10/04/2017.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation

extension String {
    // Configuration
    static let closedCaptioningHelpTitle = NSLocalizedString("Ondertiteling", comment: "Closed captioning")
    static let closedCaptioningHelpText = NSLocalizedString("De meeste programma's hebben ondertitels beschikbaar voor doven en slechthorenden. Wanneer deze optie is ingeschakeld zullen -wanneer beschikbaar- bekeken afleveringen worden ondertiteld.", comment: "Most programs have closed captioning available for the deaf and hearing impaired. Enabling this setting will -when available- display closed captioning for when watching an episode.")
    static let secureTransportHelpTitle = NSLocalizedString("Beveiligde verbinding", comment: "Secure transport")
    static let secureTransportHelpText = NSLocalizedString("Indien ingeschakeld zullen alléén beveiligde verbindingen worden gebruikt. Wanneer u zich in het buitenland bevindt en gebruik maakt van 'unlocator' dan dient u deze optie uit te schakelen.", comment: "When enabled only secure connections will be used. If you are abroad and make use of the 'unlocator' service, you should disable this option for the service to work properly.")
}
