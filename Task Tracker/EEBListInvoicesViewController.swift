//
//  EEBListInvoicesViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2016-01-03.
//  Copyright © 2016 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBListInvoicesViewController : NSViewController, NavigableViewController {
    
    /**** Top level views ****/
    @IBOutlet weak var overlayView : EEBOverlayView!
    @IBOutlet weak var customSpacerView : NSView!
    @IBOutlet weak var backgroundView : NSView!
    @IBOutlet weak var tableView : NSTableView!
    
    var navigationController : EEBNavigationController? = nil;
    var storeManager : EEBPersistentStoreManager? = nil
    var client : Client? = nil
    
    @IBAction func open(sender : AnyObject){
        print("Not implemented yet")
    }
    
    //MARK: Overlay actions
    func back(sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
