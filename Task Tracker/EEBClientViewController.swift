//
//  ViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-26.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Cocoa
import AppKit

class EEBClientViewController: EEBBaseTableViewController,EEBSimpleTableCellViewDelegate {
    
    let kDefaultIconImageName = "client128.png"
    let kRateFieldWidth = CGFloat(60)
    let kPadding = CGFloat(10)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        kRowHeight = 114.0
        kTVObjectType = "Client"
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true

        assert(sm != nil, "Persistent store manager nil in ClientVieController \(self)")
        timer = EEBTimer(storeManager:sm!)
    }
    
    override func becomeFirstResponder() -> Bool {
        return false
    }
            
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //Get the object of which we wish to display the properties
        if let currentObject = self.sm!.allObjectsOfType(self.kTVObjectType)?[row] as? Client {

            if let simpleCellView = tableView.makeViewWithIdentifier("simpleCellView", owner: nil) as? EEBSimpleTableCellView {
                simpleCellView.headerImage = NSImage(named: "client128")
                simpleCellView.delegate = self;
                
                //setup textfields in contentview
                let frame = simpleCellView.contentFrame
                let companyNameRect = CGRectMake(0.0, 5.0, frame.size.width - (kRateFieldWidth + kPadding),25.0)
                let companyNameView = NSTextField(frame: companyNameRect)
                companyNameView.font = NSFont(name: "Helvetica Neue Light", size: 15.0)
                companyNameView.stringValue = currentObject.company == nil ? "" : currentObject.company!
                companyNameView.textColor = NSColor.lightGrayColor()
                companyNameView.editable = true
                companyNameView.selectable = true
                companyNameView.bordered = false
                companyNameView.focusRingType = .None
                companyNameView.target = self
                companyNameView.identifier = "company"
                companyNameView.action = Selector("textfieldEdited:")
                
                let clientNameRect = CGRectMake(0.0, 30.0, frame.size.width ,25.0)
                let clientNameView = NSTextField(frame: clientNameRect)
                clientNameView.stringValue = currentObject.name!
                clientNameView.font = NSFont(name: "Helvetica Neue Light", size: 22.0)
                clientNameView.editable = true
                clientNameView.selectable = true
                clientNameView.bordered = false
                clientNameView.focusRingType = .None
                clientNameView.target = self
                clientNameView.identifier = "name"
                clientNameView.action = Selector("textfieldEdited:")
                
                let clientRateRect = CGRectMake(frame.size.width - kRateFieldWidth, companyNameRect.origin.y, kRateFieldWidth,25.0)
                let clientRateView = NSTextField(frame: clientRateRect)
                clientRateView.font = NSFont(name: "Helvetica Neue Light", size: 15.0)
                clientRateView.alignment = .Right
                clientRateView.editable = true
                clientRateView.selectable = true
                clientRateView.bordered = false
                clientRateView.focusRingType = .None
                clientRateView.target = self
                clientRateView.identifier = "rateString"
                clientRateView.action = Selector("textfieldEdited:")
                
                let nf = NSNumberFormatter()
                nf.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                clientRateView.formatter = nf
                clientRateView.stringValue = currentObject.rateString
                
                simpleCellView.contentView?.addSubview(companyNameView)
                simpleCellView.contentView?.addSubview(clientNameView)
                simpleCellView.contentView?.addSubview(clientRateView)

                clientRateView.translatesAutoresizingMaskIntoConstraints = false
                clientRateView.leadingAnchor.constraintEqualToAnchor(companyNameView.trailingAnchor).active = true
                clientRateView.topAnchor.constraintEqualToAnchor(companyNameView.topAnchor).active = true
                clientRateView.bottomAnchor.constraintEqualToAnchor(companyNameView.bottomAnchor).active = true
                clientRateView.trailingAnchor.constraintEqualToAnchor(simpleCellView.contentView!.trailingAnchor).active = true
                return simpleCellView
            }

        }
        return nil;
    }
    
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if(!self.allowSelection){
            return false
        }
        return true
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let items = self.view.window?.toolbar?.items.filter({$0.itemIdentifier == kToolbarItemIdentifierRun})
        if(items?.count > 0){
            items?.first?.enabled = false
        }
    }
    
    override func textfieldEdited(sender: NSTextField) {
        super.textfieldEdited(sender)
        
        let rowIndex = tableView.rowForView(sender)
        if let client = self.sm!.allObjectsOfType(self.kTVObjectType)?[rowIndex] as? Client {
            if let jobsSet = client.jobs.set as? Set<Job>{
                let newJobs = jobsSet.map({
                    (let job) -> Job  in
                    job.client = client
                    return job
                })
                client.jobs = NSMutableOrderedSet(array: newJobs)
            }
        }
        
    }
 
    //MARK: IBActions
    override func remove(sender : AnyObject){
        //code
        let rowIdx = self.tableView.selectedRow
        if let currentObject = sm!.allObjectsOfType(kTVObjectType)?[rowIdx] as? Client {
            sm!.removeObject(currentObject)
            sm!.save()
        }
        self.tableView.reloadData()
    }
    
    override func add(sender : AnyObject){
        if let createdObject = sm!.createObjectOfType(kTVObjectType) as? Client {
            createdObject.name = "Jane Doe"
            createdObject.hourlyRate = 90.0
            sm!.save()
        }
        self.tableView.reloadData()
    }
    override func run(sender : AnyObject){
        guard timer != nil else {
            return
        }
        
        let result = (timer?.stopTimingSession())!
        if(result){
            (sender as! NSButton).state = NSOffState
        }
        (sender as! NSButton).enabled = (tableView.selectedRow != -1)
    }
    
    func disclosureButtonPressed(sender: AnyObject) {
        //show jobs for the selected client
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("jobsViewController") as? EEBJobViewController {
            vc.navigationController = self.navigationController
            vc.sm = sm
            vc.timer = timer
            
            //This method is invoked with the calling object as sender, which is the parent TableCellView
            if let view = sender as? NSView {
                let rowIdx = tableView.rowForView(view)
                vc.client = self.sm!.allObjectsOfType(self.kTVObjectType)?[rowIdx] as? Client
            }

            self.navigationController?.pushViewController(vc, true)
        }
    }
}

