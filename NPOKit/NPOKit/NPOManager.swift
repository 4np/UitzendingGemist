//
//  NPOManager.swift
//  NPOKit
//
//  Created by Jeroen Wesbeek on 13/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Alamofire

public enum NPOError: ErrorType {
    case ModelMappingError(String)//, JSON)
    case TokenError(String)
    case NetworkError(String)
    case NoImageError
    case NoMIDError
}

public enum NPOGenre: String {
    case Amusement = "Amusement"
    case Documentary = "Documentaire"
    case Film = "Film"
    case Informative = "Informatief"
    case Music = "Muziek"
    case Nature = "Natuur"
    case Sport = "Sport"
    case Youth = "Jeugd"
    
    static let all = [Amusement, Documentary, Film, Informative, Music, Nature, Sport, Youth]
}

public enum NPOBroadcaster: String {
    case VARA = "VARA"
    case NOS = "NOS"
    //case KRO = "KRO"
    //case NCRV = "NCRV"
    case NCRV = "KRO-NCRV"
    //case AVRO = "AVRO"
    //case TROS = "TROS"
    case AVROTROS = "AVROTROS"
    case BNN = "BNN"
    case EO = "EO"
    case HUMAN = "HUMAN"
    case MAX = "MAX"
    case NTR = "NTR"
    case VPRO = "VPRO"
    case WNL = "WNL"
    case PowNed = "PowNed"
    
    static let all = [VARA, NOS, AVROTROS, BNN, EO, HUMAN, MAX, NTR, VPRO, WNL, PowNed]
}

public class NPOManager {
    public static let sharedInstance = NPOManager()
    internal let baseURL = "http://apps-api.uitzendinggemist.nl"
    private let infoDictionary = NSBundle.mainBundle().infoDictionary
    
    //MARK: Get url
    
    internal func getURL(forPath path: String) -> String {
        return "\(self.baseURL)/\(path)"
    }
    
    //MARK: Request headers
    
    internal func getHeaders() -> [String:String] {
        return [
            //"User-Agent"        : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/601.2.7 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.7",
            "DNT"               : "1",
            "Accept-Encoding"   : "gzip, deflate, sdch",
            "Accept"            : "*/*",
            "X-UitzendingGemist-Version"        : (infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"),
            "X-UitzendingGemist-Source"         : "https://github.com/4np/NPOKit",
            "X-UitzendingGemist-Platform"       : (infoDictionary?["DTSDKName"] as? String ?? "unknown"),
            "X-UitzendingGemist-PlatformVersion": (infoDictionary?["DTPlatformVersion"] as? String ?? "unknown")
        ]
    }
}
