//
//  AppDelegate.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-26.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didStartTimer:"), name: kJobTimingSessionDidStartNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didStopTimer:"), name: kJobTimingSessionDidStopNotification, object: nil)

        
        

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        if let navigationController = NSApplication.sharedApplication().keyWindow?.contentViewController as? EEBNavigationController {
            navigationController.applicationWillTerminate()
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    func didStartTimer(notification : NSNotification){
        NSApp.applicationIconImage = NSImage(named:"watch_icon_play")
    }
    
    func didStopTimer(notification : NSNotification){
        NSApp.applicationIconImage = nil
    }


}

