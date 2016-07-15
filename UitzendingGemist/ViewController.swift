//
//  ViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 13/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import UIKit
import NPOKit
import CocoaLumberjack

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        NPOManager.sharedInstance.getPrograms { programs, error in
//            guard let programs = programs else {
//                DDLogError("error fetching programs: \(error)")
//                return
//            }
//            
//            DDLogDebug("\(programs.count) programs, first program: \(programs.first)")
//        }
//        
//        NPOManager.sharedInstance.getTips() { tips, error in
//            guard let tips = tips else {
//                DDLogError("error fetching tips: \(error)")
//                return
//            }
//            
//            DDLogDebug("\(tips.count) tips, first tip: \(tips.first)")
//        }
//        
//        NPOManager.sharedInstance.getPopularEpisodes() { episodes, error in
//            guard let episodes = episodes else {
//                DDLogError("error fetching popular episodes: \(error)")
//                return
//            }
//            
//            DDLogDebug("\(episodes.count) popular episodes, first episode: \(episodes.first)")
//        }
//        
//        NPOManager.sharedInstance.getEpisodes(forDate: NSDate()) { episodes, error in
//            guard let episodes = episodes else {
//                DDLogError("error fetching today's episodes: \(error)")
//                return
//            }
//            
//            DDLogDebug("\(episodes.count) today's episodes, first episode: \(episodes.first)")
//        }
//        
//        NPOManager.sharedInstance.getRecentEpisodes() { episodes, error in
//            guard let episodes = episodes else {
//                DDLogError("error fetching recent episodes: \(error)")
//                return
//            }
//            
//            DDLogDebug("\(episodes.count) recent episodes, first episode: \(episodes.first)")
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
