//
//  ViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-26.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Cocoa
import AppKit

class EEBJobViewController: EEBBaseTableViewController, NSTextFieldDelegate, EEBTimingSessionsViewControllerDelegate {
    
    @IBOutlet weak var overlayView : EEBOverlayView!
    @IBOutlet weak var customSpacerView : NSView!
    
    let kDefaultIconImageName = "suitcase32.png"    
    let kNameColumnIdentifier = "name"
    let kDescriptionColumnIdentifier = "description"
    let kTimeColumnIdentifier = "time"
    let kCostColumnIdentifier = "cost"

    var client : Client? = nil
    var editing : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        kRowHeight = 17.0
        kTVObjectType = "Job"
    }
    
    override func viewDidLoad() {
        tableView.doubleAction = #selector(EEBJobViewController.doubleClicked(_:))
        tableView.target = self
        
        //Set overlay buttons
        let leftButton = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = #selector(EEBBaseTableViewController.back(_:))
        
        let btn_createInvoice = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        btn_createInvoice.image = NSImage(named:"note-plus-48")
        btn_createInvoice.target = self
        btn_createInvoice.action = #selector(EEBJobViewController.createInvoice(_:))

        let btn_showInvoices = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        btn_showInvoices.image = NSImage(named:"note-48")
        btn_showInvoices.target = self
        btn_showInvoices.action = #selector(EEBJobViewController.showInvoices(_:))
        
        overlayView.leftBarButtonItems = [leftButton]
        overlayView.rightBarButtonItems = [btn_showInvoices,btn_createInvoice]
        overlayView.text = client!.name!
        customSpacerView.layer? = CALayer()
        
        if(timer != nil && timer!.running){
            lastSelectedRowIndex = client!.jobs.index(of: timer!.job!)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(kUpdateFrequency * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: updateRow)
        }
    }
    
    override func viewDidAppear() {
                updateToolbarItems()
        customSpacerView.layer?.backgroundColor = CGColor(red: overlayView.kGradientStartColour.red, green: overlayView.kGradientStartColour.green, blue: overlayView.kGradientStartColour.blue, alpha: 1.0)
    }
    
    
    func tableView(_ tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        //stub
        return nil;
    }
    
    func tableView(_ tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard (client != nil  && client!.jobs.count > row) else {
            return nil
        }
        
        //Get the object of which we wish to display the properties
        let currentJob = client?.jobs[row] as! Job
        let view = NSTextField()
        
        switch(tableColumn!.identifier){
            case kNameColumnIdentifier:
                if let cellView = tableView.make(withIdentifier: "nameCell", owner: self) as? NSTableCellView{
                    cellView.textField?.stringValue = currentJob.name
                    cellView.textField?.delegate = self
                    cellView.textField?.isEditable = true
                    cellView.textField?.target = self
                    cellView.textField?.action = #selector(EEBBaseTableViewController.textfieldEdited(_:))
                    cellView.textField?.identifier = "name"
                    return cellView
                }
                
                break;
            case kDescriptionColumnIdentifier:
                if let cellView = tableView.make(withIdentifier: "nameCell", owner: self) as? NSTableCellView{
                    cellView.textField?.stringValue = (currentJob.jobDescription == nil) ? "" : currentJob.jobDescription!
                    cellView.textField?.isEditable = true
                    cellView.textField?.delegate = self
                    cellView.textField?.target = self
                    cellView.textField?.action = #selector(EEBBaseTableViewController.textfieldEdited(_:))
                    cellView.textField?.identifier = "jobDescription"
                    return cellView
                }
                break;
            case kTimeColumnIdentifier:
                if let cellView = tableView.make(withIdentifier: "nameCell", owner: self) as? NSTableCellView {
                    cellView.textField?.stringValue = currentJob.totalTimeString()
                    cellView.textField?.isEditable = false
                    
                    //embed recessed button
//                    let quickAdd = NSButton(frame: CGRectMake(cellView.frame.size.width - tableView.rowHeight ,0,tableView.rowHeight,tableView.rowHeight))
//                    quickAdd.bezelStyle = .InlineBezelStyle
//                    quickAdd.stringValue = ""
//                    quickAdd.image = NSImage(named: NSImageNameAddTemplate)
//                    quickAdd.setButtonType(.MomentaryPushInButton)
//                    cellView.addSubview(quickAdd)
                    
                    return cellView
                }
                break;
            case kCostColumnIdentifier:
                if let cellView = tableView.make(withIdentifier: "nameCell", owner: self) as? NSTableCellView{
                    cellView.textField?.stringValue = currentJob.cost()
                    cellView.textField?.isEditable = false
                    return cellView
                }
                break
            default:
                break;
        }
        return view
    }
    
    override func numberOfRows(in tableView: NSTableView) -> Int {
        return (client == nil || client?.jobs == nil) ? 0 : (client?.jobs.count)!
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if(tableView.selectedRow != -1){
            lastSelectedRowIndex = tableView.selectedRow
        }
        updateToolbarItems()

    }
    
    func updateToolbarItems(){
        let items = self.view.window?.toolbar?.items.filter({$0.itemIdentifier == kToolbarItemIdentifierRun})
        items?.first?.isEnabled = (tableView.selectedRow != -1) || ((items?.first?.view as! NSButton).state == NSOnState)
        
        let deleteItems = self.view.window?.toolbar?.items.filter({$0.itemIdentifier == kToolbarItemIdentifierDelete})
        deleteItems?.first?.isEnabled = (tableView.selectedRow != -1) || ((deleteItems?.first?.view as! NSButton).state == NSOnState)
    }
    
    /**
     * @name 	textFieldEdited
     * @brief   Method called to update the model when a textfield in the tableview has been changed
     */

    override func textfieldEdited(_ sender: NSTextField) {
        guard tableView.selectedRow != -1  else {
            return 
        }
        
        if let currentJob = client?.jobs[tableView.selectedRow] as? Job {
            currentJob.setValue(sender.stringValue, forKey: sender.identifier!)
            sm!.save()
            
            if(timer!.running){
                NotificationCenter.default.post(name: Notification.Name(rawValue: kJobDidUpdateNotification), object: currentJob)
            }
        }
    }
    
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        editing = true
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        editing = false
    }
    
    func doubleClicked(_ sender : AnyObject){
        if(sender.clickedColumn == tableView.column(withIdentifier: kTimeColumnIdentifier)){
            let currentJob = client?.jobs[sender.clickedRow] as? Job
            if let vc = self.storyboard?.instantiateController(withIdentifier: "timingViewController") as? EEBTimingSessionsViewController {
                vc.job = currentJob
                vc.delegate = self
                vc.sm = sm
                
                let popover = NSPopover()
                popover.delegate = vc
                popover.behavior = .transient
                popover.contentViewController = vc
                popover.contentSize = vc.view.bounds.size
                popover.show(relativeTo: NSMakeRect(0, 0, 50, 50), of: tableView.view(atColumn: sender.clickedColumn, row: sender.clickedRow, makeIfNecessary: false)!, preferredEdge: NSRectEdge.minY)
                vc.popover = popover
                
            }
            
        } else {
            let view = tableView.view(atColumn: sender.clickedColumn, row: sender.clickedRow, makeIfNecessary: false) as? NSTableCellView
            if view?.textField?.isEditable == true {
                view?.window?.makeFirstResponder(view?.textField)
            }
        }
    }

    func doneEditing() {
        tableView.reloadData()
    }
    
    /**
     * @name    updateRow
     * @brief   When a timing session is running, we need to update the row 
     *          to which that job belongs. This method takes care of that
     */
    func updateRow(){
        guard timer != nil && timer!.job != nil else {
            return
        }
        
        if let currentJob = timer?.job, let jobIdx = client?.jobs.index(of: timer!.job!) {
            
            let timeCellView = tableView(tableView, viewForTableColumn: NSTableColumn(identifier:kTimeColumnIdentifier), row: jobIdx) as? NSTableCellView
            let costCellView = tableView(tableView, viewForTableColumn: NSTableColumn(identifier: kCostColumnIdentifier), row: jobIdx) as? NSTableCellView
            timeCellView?.textField?.stringValue = currentJob.totalTimeString()
            costCellView?.textField?.stringValue = currentJob.cost()
            
            let idxSet = NSMutableIndexSet(index: tableView.column(withIdentifier: kTimeColumnIdentifier))
            idxSet.add(tableView.column(withIdentifier: kCostColumnIdentifier))
            
            tableView.beginUpdates()
            tableView.reloadData(forRowIndexes: IndexSet(integer:jobIdx), columnIndexes: idxSet as IndexSet)
            tableView.endUpdates()
        }
        
        //repeat
        if(timer!.running){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(kUpdateFrequency * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: updateRow)
        }
    }
    
    //MARK: IBActions
    
    //Remove the selected job from the DB
    override func remove(_ sender : AnyObject){
        guard tableView.selectedRowIndexes.count > 0 && editing == false  else {
            return
        }
        
        let jobsToRemove = tableView.selectedRowIndexes.map() {client?.jobs[$0] }
        jobsToRemove.forEach() { sm!.removeObject($0 as! Job)}

        sm!.save()
        self.tableView.reloadData()
    }
    
    //Add a new item of type Job to the DB
    override func add(_ sender : AnyObject){
        guard editing == false else {
            return
        }
        
        if let createdObject = sm!.createObjectOfType(self.kTVObjectType) as? Job {
            createdObject.name = "Untitled Job"
            createdObject.client = client!
            createdObject.creationDate = Date()
            client!.jobs.add(createdObject)
            sm!.save()
        }
        self.tableView.reloadData()
    }
    
    func enterPressed(){
        if(!editing){
            print("not editing")
        }
    }
    
    //MARK: Overlay actions
    override func back(_ sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showInvoices(_ sender : AnyObject){
        if let vc = self.storyboard?.instantiateController(withIdentifier: "listInvoicesViewController") as? EEBListInvoicesViewController {
            vc.navigationController = self.navigationController
            vc.storeManager = sm
            vc.client = client
            
            self.navigationController?.pushViewController(vc, true)      
        }
    }
    
    func createInvoice(_ sender : AnyObject){
        if let vc = self.storyboard?.instantiateController(withIdentifier: "createInvoiceViewController") as? EEBCreateInvoiceViewController {
            vc.navigationController = self.navigationController
            vc.storeManager = sm
            vc.client = client
            
            //Set set of selected jobs
            if let jobs = client!.jobs.objects(at: tableView.selectedRowIndexes) as? [Job] {
                vc.jobs = jobs
            }
            
            self.navigationController?.pushViewController(vc, true)            
        }
    }
    
    /**
     * @name run
     * @brief Method called when the run button is pressed. Note that part of the 
     * run functionality is in the ClientViewController class
      */
    override func run(_ sender : AnyObject){
        guard(timer != nil && editing == false) else {
            return
        }
                
        if(timer!.running){
            let result = (timer?.stopTimingSession())!
            if(result){
                (sender as! NSButton).state = NSOffState
            }
            (sender as! NSButton).isEnabled = (tableView.selectedRow != -1)
        } else {
            guard (tableView.selectedRow != -1) else {
                (sender as! NSButton).isEnabled = false
                return
            }
            
            if let currentJob = client?.jobs[tableView.selectedRow] as? Job {
                let result = (timer?.startTimingSession(currentJob))!
                if(result){
                    (sender as! NSButton).state = NSOnState
                    //Periodically update the appropriate row
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(kUpdateFrequency * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: updateRow)
                    
                }
            }
        }
    }

}

