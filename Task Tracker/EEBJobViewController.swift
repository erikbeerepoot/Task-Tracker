//
//  ViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-26.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Cocoa
import AppKit

class EEBJobViewController: EEBBaseTableViewController {
    
    @IBOutlet weak var overlayView : EEBOverlayView!
    
    let kDefaultIconImageName = "suitcase32.png"
    var client : Client? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        kRowHeight = 32.0
        kTVObjectType = "Job"
    }
    
    override func viewDidLoad() {
        //Set overlay
        let leftButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = Selector("back:")
        
        let settingsButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        settingsButton.image = NSImage(named:"settings-48")
        settingsButton.target = self
        settingsButton.action = Selector("settings:")
        
        let invoicesButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        invoicesButton.image = NSImage(named:"square-inc-cash-48")
        invoicesButton.target = self
        invoicesButton.action = Selector("invoices:")
        
        overlayView.leftBarButtonItems = [leftButton]
        overlayView.rightBarButtonItems = [settingsButton,invoicesButton]
    }
    
    override func viewWillAppear() {
        
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        //stub
        return nil;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        //Get the object of which we wish to display the properties
        if let currentObject = sm.allObjectsOfType(kTVObjectType)?[row] as? Job {

        }
        return nil;
    }
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (client == nil || client?.jobs == nil) ? 0 : (client?.jobs?.count)!
    }
    
    func tableView(tableView: NSTableView, shouldSelectTableColumn tableColumn: NSTableColumn?) -> Bool {
        return true
    }
    
    //MARK: IBActions
    @IBAction override func remove(sender : AnyObject){
        //code
        let rowIdx = self.tableView.selectedRow
        if let currentObject = sm.allObjectsOfType(self.kTVObjectType)?[rowIdx] as? Job {
            sm.removeObject(currentObject)
        }
        self.tableView.reloadData()
    }
    
    @IBAction override func add(sender : AnyObject){
        if let createdObject = sm.createObjectOfType(self.kTVObjectType) as? Job {
            createdObject.name = "New"
            client?.jobs?.addObject(createdObject)
        }
        self.tableView.reloadData()
    }
    
    //MARK: Overlay actions
    func back(sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func settings(sender : AnyObject){
        //stub
    }
    
    func showInvoices(sender : AnyObject){
        //stub        
    }

}

