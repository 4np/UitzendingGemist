//
//  ConfigurationViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 22/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit

class ConfigurationViewController: UIViewController {
    @IBOutlet weak var closedCaptioningSegmentedControl: UISegmentedControl!
    
    private var closedCaptioningIsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UitzendingGemistConstants.closedCaptioningEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UitzendingGemistConstants.closedCaptioningEnabledKey)
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closedCaptioningSegmentedControl.selectedSegmentIndex = (closedCaptioningIsEnabled) ? 0 : 1
    }
    
    // MARK: Settings changed
    
    @IBAction func closedCaptioningSegmentedControlChanged(_ sender: UISegmentedControl) {
        closedCaptioningIsEnabled = (closedCaptioningSegmentedControl.selectedSegmentIndex == 0)
    }
}
