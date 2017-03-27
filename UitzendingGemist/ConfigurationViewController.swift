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
    @IBOutlet weak var secureTransportSegmentedControl: UISegmentedControl!
    
    private var closedCaptioningIsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UitzendingGemistConstants.closedCaptioningEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UitzendingGemistConstants.closedCaptioningEnabledKey)
        }
    }
    
    private var secureTransportIsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UitzendingGemistConstants.secureTransportEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UitzendingGemistConstants.secureTransportEnabledKey)
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closedCaptioningSegmentedControl.selectedSegmentIndex = (closedCaptioningIsEnabled) ? 0 : 1
        secureTransportSegmentedControl.selectedSegmentIndex = (secureTransportIsEnabled) ? 0 : 1
    }
    
    // MARK: Settings changed
    
    @IBAction func closedCaptioningSegmentedControlChanged(_ sender: UISegmentedControl) {
        closedCaptioningIsEnabled = (closedCaptioningSegmentedControl.selectedSegmentIndex == 0)
    }
    
    @IBAction func secureTransportSegmentedControlChanged(_ sender: UISegmentedControl) {
        secureTransportIsEnabled = (secureTransportSegmentedControl.selectedSegmentIndex == 0)
    }
}
