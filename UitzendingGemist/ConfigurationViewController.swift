//
//  ConfigurationViewController.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 22/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import Foundation
import UIKit
import NPOKit

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
    
    private var forceSecureTransport: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UitzendingGemistConstants.forceSecureTransportKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UitzendingGemistConstants.forceSecureTransportKey)
            
            // update NPOKit
            NPOManager.sharedInstance.forceSecureTransport = newValue
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closedCaptioningSegmentedControl.selectedSegmentIndex = (closedCaptioningIsEnabled) ? 0 : 1
        secureTransportSegmentedControl.selectedSegmentIndex = (forceSecureTransport) ? 0 : 1
    }
    
    // MARK: Settings changed
    
    @IBAction func closedCaptioningSegmentedControlChanged(_ sender: UISegmentedControl) {
        closedCaptioningIsEnabled = (closedCaptioningSegmentedControl.selectedSegmentIndex == 0)
    }
    
    @IBAction func secureTransportSegmentedControlChanged(_ sender: UISegmentedControl) {
        forceSecureTransport = (secureTransportSegmentedControl.selectedSegmentIndex == 0)
    }
    
    // MARK: Help
    
    @IBAction func didPressClosedCaptioningHelpButton(_ sender: UIButton) {
        showModal(withHelpTitle: String.closedCaptioningHelpTitle, andHelpText: String.closedCaptioningHelpText)
    }
    
    @IBAction func didPressSecureTransportHelpButton(_ sender: UIButton) {
        showModal(withHelpTitle: String.secureTransportHelpTitle, andHelpText: String.secureTransportHelpText)
    }
    
    private func showModal(withHelpTitle helpTitle: String, andHelpText helpText: String) {
        let alertController = UIAlertController(title: helpTitle, message: helpText, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
