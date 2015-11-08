//
//  MainWindowController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-26.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class MainWindowController : NSWindowController {
 
    override func windowDidLoad() {
        self.window?.titleVisibility = NSWindowTitleVisibility.Hidden;
        self.window?.styleMask |= NSFullSizeContentViewWindowMask;
    }
}