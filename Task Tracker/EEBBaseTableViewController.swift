//
//  BaseTableViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-28.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBBaseTableViewController : NSViewController, NSTableViewDataSource, NSTableViewDelegate, NavigableViewController {
    //MARK: IBOutlets
    @IBOutlet weak var tableView : NSTableView!
    @IBOutlet weak var backgroundView : NSView!
    @IBOutlet weak var titleLabel : NSTextField!
    
    //MARK: Appearance
    var kRowHeight : CGFloat = 64.0
    
    //MARK: Module state
    let sm = PresistentStoreManager()
    var kTVObjectType = ""
    var navigationController : EEBNavigationController? = nil;
    var allowSelection = false;
    
    //MARK: Appearance constants
    let kIconHeader : String! = "iconHeader"
    let kNameHeader : String! = "nameHeader"
    let kIconView : String! = "iconView"
    let kNameView : String! = "nameView"
    
    override func viewWillAppear() {
        self.backgroundView.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
    
    override func viewDidAppear() {
        self.allowSelection = true;
    }
    
    override func viewWillDisappear() {
        sm.save()
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
        
    //MARK: TableView methods
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return kRowHeight
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (sm.allObjectsOfType(kTVObjectType) != nil) ? sm.allObjectsOfType(kTVObjectType)!.count : 0
    }
    
    @IBAction func add(sender : AnyObject){
        
    }
    
    @IBAction func remove(sender : AnyObject){
        
    }

}