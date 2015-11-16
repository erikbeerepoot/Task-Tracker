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
    let kTimeColumnIdentifier = "time"
    let kCostColumnIdentifier = "cost"

    var client : Client? = nil
    var timer : EEBTimer? = nil;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        kRowHeight = 17.0
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
        
        if(timer != nil && timer!.running){
            lastSelectedRowIndex = client!.jobs.indexOfObject(timer!.job!)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kUpdateFrequency * Double(NSEC_PER_SEC))), dispatch_get_main_queue(),updateRow)
        }
    }
    
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        //stub
        return nil;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard (client != nil  && client!.jobs.count > row) else {
            return nil
        }
        
        //Get the object of which we wish to display the properties
        let currentJob = Array(client!.jobs)[row] as! Job
        let view = NSTextField()
        
        switch(tableColumn!.identifier){
            case "name":
                if let cellView = tableView.makeViewWithIdentifier("nameCell", owner: self) as? NSTableCellView{
                    cellView.textField?.stringValue = currentJob.name
                    cellView.textField?.editable = true
                    cellView.textField?.target = self
                    cellView.textField?.action = Selector("textfieldEdited:")
                    cellView.textField?.identifier = "name"
                    return cellView
                }
                
                break;
            case "description":
                if let cellView = tableView.makeViewWithIdentifier("nameCell", owner: self) as? NSTableCellView{
                    cellView.textField?.stringValue = (currentJob.jobDescription == nil) ? "" : currentJob.jobDescription!
                    cellView.textField?.editable = true
                    cellView.textField?.target = self
                    cellView.textField?.action = Selector("textfieldEdited:")
                    cellView.textField?.identifier = "jobDescription"
                    return cellView
                }
                break;
            case kTimeColumnIdentifier:
                if let cellView = tableView.makeViewWithIdentifier("nameCell", owner: self) as? NSTableCellView{
                    cellView.textField?.stringValue = currentJob.totalTimeString()
                    cellView.textField?.editable = false
                    
                    return cellView
                }
                break;
            case kCostColumnIdentifier:
                if let cellView = tableView.makeViewWithIdentifier("nameCell", owner: self) as? NSTableCellView{
                    cellView.textField?.stringValue = currentJob.cost()
                    cellView.textField?.editable = false
                    return cellView
                }
                break
            default:
                break;
        }
        return view
    }
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (client == nil || client?.jobs == nil) ? 0 : (client?.jobs.count)!
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if(tableView.selectedRow != -1){
            lastSelectedRowIndex = tableView.selectedRow
        }

        let items = self.view.window?.toolbar?.items.filter({$0.itemIdentifier == kToolbarItemIdentifierRun})
        if(items?.count > 0){
            items?.first?.enabled = (tableView.selectedRow != -1) || ((items?.first?.view as! NSButton).state == NSOnState)
        }
    }
    
    override func textfieldEdited(sender: NSTextField) {
        super.textfieldEdited(sender)
        
        if let currentJob = Array(client!.jobs)[tableView.selectedRow] as? Job {
            sm?.save()
            
            if(timer!.running){
                NSNotificationCenter.defaultCenter().postNotificationName(kJobDidUpdateNotification, object: currentJob)
            }
        }
    }
    
    
        
    func updateRow(){
        guard (tableView.numberOfRows > 0) && (lastSelectedRowIndex < tableView.numberOfRows) && (lastSelectedRowIndex != -1) else {
            return
        }
        
        if let cellView = tableView(tableView, viewForTableColumn: NSTableColumn(identifier:kTimeColumnIdentifier), row: lastSelectedRowIndex) as? NSTableCellView {
            let currentJob = Array(client!.jobs)[lastSelectedRowIndex] as! Job

            cellView.textField?.stringValue = currentJob.totalTimeString()

            tableView.beginUpdates()
            tableView.reloadDataForRowIndexes(NSIndexSet(index:lastSelectedRowIndex), columnIndexes: NSIndexSet(index:tableView.columnWithIdentifier(kTimeColumnIdentifier)))
            tableView.endUpdates()
        }
        
        if let cellView = tableView(tableView, viewForTableColumn: NSTableColumn(identifier: kCostColumnIdentifier), row: lastSelectedRowIndex) as? NSTableCellView {
            let currentJob = Array(client!.jobs)[lastSelectedRowIndex] as! Job
            
            cellView.textField?.stringValue = currentJob.cost()
            
            tableView.beginUpdates()
            tableView.reloadDataForRowIndexes(NSIndexSet(index:lastSelectedRowIndex), columnIndexes: NSIndexSet(index:tableView.columnWithIdentifier(kCostColumnIdentifier)))
            tableView.endUpdates()
        }
        
        //repeat
        if(timer!.running){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kUpdateFrequency * Double(NSEC_PER_SEC))), dispatch_get_main_queue(),updateRow)
        }
    }
    
    //MARK: IBActions
    @IBAction override func remove(sender : AnyObject){
        //code
        let rowIdx = self.tableView.selectedRow
        if let currentObject = sm!.allObjectsOfType(self.kTVObjectType)?[rowIdx] as? Job {
            sm!.removeObject(currentObject)
        }
        self.tableView.reloadData()
    }
    
    @IBAction override func add(sender : AnyObject){
        if let createdObject = sm!.createObjectOfType(self.kTVObjectType) as? Job {
            createdObject.name = "Untitled Job"
            createdObject.client = client!
            client!.jobs.addObject(createdObject)
            sm!.save()
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
    
    
    @IBAction override func run(sender : AnyObject){
        guard(timer != nil) else {
            return
        }
                
        if(timer!.running){
            let result = (timer?.stopTimingSession())!
            if(result){
                (sender as! NSButton).state = NSOffState
            }
            (sender as! NSButton).enabled = (tableView.selectedRow != -1)
        } else {
            guard (tableView.selectedRow != -1) else {
                (sender as! NSButton).enabled = false
                return
            }
            
            let currentJob = Array(client!.jobs)[tableView.selectedRow] as! Job
            let result = (timer?.startTimingSession(currentJob))!
            if(result){
                (sender as! NSButton).state = NSOnState
                //Periodically update the appropriate row
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kUpdateFrequency * Double(NSEC_PER_SEC))), dispatch_get_main_queue(),updateRow)
                
            }
        }
    }

}

