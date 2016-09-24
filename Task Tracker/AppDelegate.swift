//
//  AppDelegate.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-26.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didStartTimer(_:)), name: NSNotification.Name(rawValue: kJobTimingSessionDidStartNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didStopTimer(_:)), name: NSNotification.Name(rawValue: kJobTimingSessionDidStopNotification), object: nil)
        Fabric.with([Crashlytics.self])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if let navigationController = NSApplication.shared().keyWindow?.contentViewController as? EEBNavigationController {
            navigationController.applicationWillTerminate()
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    

    func didStartTimer(_ notification : Notification){
        NSApp.applicationIconImage = NSImage(named:"watch_icon_play")
    }
    
    func didStopTimer(_ notification : Notification){
        NSApp.applicationIconImage = nil
    }


}

