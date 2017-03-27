//
//  AppDelegate.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 13/07/16.
//  Copyright © 2016 Jeroen Wesbeek. All rights reserved.
//

import UIKit
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupLoggers()
        
        // Disable closed captioning (Teletext 888) by default
        UserDefaults.standard.register(defaults: [
            UitzendingGemistConstants.closedCaptioningEnabledKey: false,
            UitzendingGemistConstants.secureTransportEnabledKey: true
        ])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Logging

    fileprivate func setupLoggers() {
        // see https://gist.github.com/erica/d20639b409fe1b318c0e
        let logLevel: DDLogLevel = _isDebugAssertConfiguration() ? .verbose : .warning
        
        DDLog.add(DDASLLogger.sharedInstance, with: logLevel)  // ASL = Apple System Logs
        DDLog.add(DDTTYLogger.sharedInstance, with: logLevel)  // TTY = Xcode console
        DDTTYLogger.sharedInstance.colorsEnabled = true        //       use colors
    }
    
    // MARK: Memory warning and logging
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        DDLogError("Did receive memory warning (\(getMegabytesUsed()) MB)")
    }
    
    func mach_task_self() -> task_t {
        return mach_task_self_
    }
    
    func getMegabytesUsed() -> Float? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
            return infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { (machPtr: UnsafeMutablePointer<integer_t>) in
                return task_info(
                    mach_task_self(),
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    machPtr,
                    &count
                )
            }
        }
        guard kerr == KERN_SUCCESS else {
            return nil
        }
        return Float(info.resident_size) / (1024 * 1024)   
    }
}
