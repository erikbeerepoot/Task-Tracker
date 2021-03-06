//
//  ViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-26.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Cocoa
import AppKit

class EEBClientViewController: EEBBaseTableViewController,EEBSimpleTableCellViewDelegate, NSTextFieldDelegate {
    
    let kCellIdentifier = "simpleCellView"
    let kRateFieldWidth = CGFloat(70)
    let kPadding = CGFloat(10)
    let kButtonWidth = CGFloat(75)
    let kButtonHeight = CGFloat(18)
    let kButtonOffset = CGFloat(10)
    var clients : [Client] = []
    func fetchClients(){
        assert(sm != nil, "Persistent store manager nil in ClientVieController \(self)")
        if let fetchedClients = (self.sm!.allObjectsOfType(self.kTVObjectType) as? [Client]){
            clients = fetchedClients
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        kTVObjectType = "Client"
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true

        //Since we set the height in the storyboard, we should get it dynamically rather than using a magic number
        if  let view = tableView.makeViewWithIdentifier(kCellIdentifier, owner: nil){
            kRowHeight = view.bounds.size.height
        }

        timer = EEBTimer(storeManager:sm!)
        
        fetchClients()
    }
    
    override func viewWillAppear() {
        updateSelection()
        fetchClients()
        tableView.reloadData()
    }
    
    
    override func becomeFirstResponder() -> Bool {
        return false
    }    
            
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //Get the object of which we wish to display the properties
        let currentObject = clients[row]

        if let simpleCellView = tableView.makeViewWithIdentifier(kCellIdentifier, owner: self) as? EEBSimpleTableCellView {
            
            if let companyNameView = simpleCellView.viewWithTag(200) as? NSTextField{
                companyNameView.stringValue = currentObject.company
            } else {
                let companyNameRect = CGRectMake(0.0, simpleCellView.contentFrame.size.height - 57.0, simpleCellView.contentFrame.size.width - (kRateFieldWidth + kPadding),25.0)
                let companyNameView = NSTextField(frame: companyNameRect)
                companyNameView.font = NSFont(name: "Helvetica Neue Light", size: 15.0)
                companyNameView.stringValue = currentObject.company
                companyNameView.textColor = NSColor.lightGrayColor()
                companyNameView.editable = true
                companyNameView.selectable = true
                companyNameView.bordered = false
                companyNameView.focusRingType = .None
                companyNameView.target = self
                companyNameView.identifier = "company"
                companyNameView.tag = 200
                companyNameView.delegate = self
                companyNameView.action = Selector("textfieldEdited:")
                
                simpleCellView.contentView?.addSubview(companyNameView)
            }
            
            
            if let clientNameView = simpleCellView.viewWithTag(201) as? NSTextField {
                clientNameView.stringValue = currentObject.name!
            } else {
                let clientNameRect = CGRectMake(0.0, simpleCellView.contentFrame.size.height - 35.0, simpleCellView.contentFrame.size.width ,25.0)
                let clientNameView = NSTextField(frame: clientNameRect)
                clientNameView.stringValue = currentObject.name!
                clientNameView.font = NSFont(name: "Helvetica Neue Light", size: 22.0)
                clientNameView.editable = true
                clientNameView.selectable = true
                clientNameView.bordered = false
                clientNameView.focusRingType = .None
                clientNameView.target = self
                clientNameView.delegate = self
                clientNameView.identifier = "name"
                clientNameView.tag = 201
                clientNameView.action = Selector("textfieldEdited:")

                simpleCellView.contentView?.addSubview(clientNameView)
            }
            
            if let clientRateView = simpleCellView.viewWithTag(202) as? NSTextField {
                clientRateView.stringValue = currentObject.rateString
            } else {
                let companyNameRect = CGRectMake(0.0, 5.0, simpleCellView.contentFrame.size.width - (kRateFieldWidth + kPadding),25.0)
                let clientRateRect = CGRectMake(simpleCellView.contentFrame.size.width - kRateFieldWidth, companyNameRect.origin.y, kRateFieldWidth,25.0)
                let clientRateView = NSTextField(frame: clientRateRect)
                clientRateView.font = NSFont(name: "Helvetica Neue Light", size: 15.0)
                clientRateView.alignment = .Right
                clientRateView.editable = true
                clientRateView.selectable = true
                clientRateView.bordered = false
                clientRateView.focusRingType = .None
                clientRateView.target = self
                clientRateView.delegate = self
                clientRateView.identifier = "rateString"
                clientRateView.tag = 202
                clientRateView.action = Selector("textfieldEdited:")
                
                simpleCellView.contentView?.addSubview(clientRateView)

                let companyNameView = simpleCellView.viewWithTag(200) as! NSTextField
                clientRateView.translatesAutoresizingMaskIntoConstraints = false
                clientRateView.leadingAnchor.constraintEqualToAnchor(companyNameView.trailingAnchor).active = true
                clientRateView.topAnchor.constraintEqualToAnchor(companyNameView.topAnchor).active = true
                clientRateView.bottomAnchor.constraintEqualToAnchor(companyNameView.bottomAnchor).active = true
                clientRateView.trailingAnchor.constraintEqualToAnchor(simpleCellView.contentView!.trailingAnchor).active = true
                    
                let nf = NSNumberFormatter()
                nf.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                clientRateView.formatter = nf
                clientRateView.stringValue = currentObject.rateString
            }
            
            if let _ = simpleCellView.viewWithTag(204) as? EEBBorderedPictureButton {
            } else {
                let settingsButtonRect = CGRectMake(0, kButtonOffset, kButtonHeight,kButtonHeight)
                let settingsButton = EEBBorderedPictureButton(frame: settingsButtonRect)
                settingsButton.image = NSImage(named:"settings-48")

                settingsButton.borderThickness = 0
                settingsButton.target = self
                settingsButton.action = Selector("settings:")

                simpleCellView.contentView?.addSubview(settingsButton)
                
            }
            
            
            if let numJobsButton = simpleCellView.viewWithTag(205) as? EEBBorderedColourButton {
                //stub
                if(currentObject.jobs.count == 0){
                   numJobsButton.hidden = true
                } else {
                    numJobsButton.hidden = false
                    numJobsButton.text = String(currentObject.jobs.count) + (currentObject.jobs.count == 1 ? " job" : " jobs")
                }
            } else {
                let numJobsRect = CGRectMake(kButtonHeight+kPadding, kButtonOffset, kButtonWidth,kButtonHeight)
                let numJobsButtonView = EEBBorderedColourButton(frame: numJobsRect)
                numJobsButtonView.borderColor = kNumJobsButtonBorderColor
                numJobsButtonView.backgroundColor = kNumJobsButtonBackgroundColor
                numJobsButtonView.tag = 205
                numJobsButtonView.target = self
                numJobsButtonView.action = Selector("disclosureButtonPressed:")                
                simpleCellView.contentView?.addSubview(numJobsButtonView)
            }
            
            if let outstandingInvoices = simpleCellView.viewWithTag(206) as? EEBBorderedColourButton {
                if currentObject.invoices.count == 0 {
                    outstandingInvoices.hidden = true
                } else {
                    let outstandingInvoiceCount = currentObject.invoices.filter({
                        if let invoice = $0 as? Invoice {
                            return !invoice.paid
                        }
                        return false
                    }).count
                    outstandingInvoices.target = self
                    outstandingInvoices.action = Selector("showInvoice:")
                    outstandingInvoices.hidden = (outstandingInvoiceCount == 0)
                    outstandingInvoices.text = String(outstandingInvoiceCount) + (outstandingInvoiceCount == 1 ? " unpaid invoice" : " unpaid invoices")
                    
                }
            } else {
                let outstandingInvRect = CGRectMake(kButtonHeight + kButtonWidth + 2*kPadding, kButtonOffset, 1.5*kButtonWidth,kButtonHeight)
                let outstandingInvButtonView = EEBBorderedColourButton(frame: outstandingInvRect)
                outstandingInvButtonView.borderColor = kOutstandingInvoicesButtonBorderColor
                outstandingInvButtonView.backgroundColor = kOutstandingInvoicesButtonBackgroundColor
                outstandingInvButtonView.tag = 206
                simpleCellView.contentView?.addSubview(outstandingInvButtonView)
            }

            
            simpleCellView.delegate = self
            simpleCellView.selected = false
            if(row==tableView.selectedRow){
                simpleCellView.selected = true
            }

            return simpleCellView
        }
        return nil
    }
    
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if(!self.allowSelection){
            return false
        }
        return true
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let items = self.view.window?.toolbar?.items.filter({$0.itemIdentifier == kToolbarItemIdentifierDelete})
        items?.first?.enabled = (tableView.selectedRow > -1)
        
        let runItems = self.view.window?.toolbar?.items.filter({$0.itemIdentifier == kToolbarItemIdentifierRun})
        runItems?.first?.enabled = self.timer!.running
        
        updateSelection()
    }
    
    
    func updateSelection(){
        
        for (var idx = 0; idx < tableView.numberOfRows; idx++){
            if let view = tableView.rowViewAtRow(idx, makeIfNecessary: false)?.viewAtColumn(0) as? EEBSimpleTableCellView {
                view.selected = false
            }
        }
        
        if tableView.selectedRow > -1 {
            if let view = tableView.rowViewAtRow(tableView.selectedRow, makeIfNecessary: false)?.viewAtColumn(0) as? EEBSimpleTableCellView {
                view.selected = true
            }
        }

    }
    
    override func controlTextDidEndEditing(notification: NSNotification) {
        if let textField = notification.object as? NSTextField {
            self.textfieldEdited(textField)
        }
    }
    
    override func textfieldEdited(sender: NSTextField) {
        //eesuper.textfieldEdited(sender)
        
        let rowIndex = tableView.rowForView(sender)
        guard (rowIndex > -1 ) else {
            return
        }
        
        let client = clients[rowIndex]
        client.setValue(sender.stringValue, forKey: sender.identifier!)
        sm?.save()

        if let jobsSet = client.jobs.set as? Set<Job>{
            let newJobs = jobsSet.map({
                (let job) -> Job  in
                job.client = client
                return job
            })
            client.jobs = NSMutableOrderedSet(array: newJobs)
        }
    
    }
 
    //MARK: IBActions
    override func remove(sender : AnyObject){
        guard(tableView.selectedRow > -1) else {
            return
        }
        
        //code
        let rowIdx = tableView.selectedRow
        if(rowIdx > -1 && rowIdx < clients.count){
            sm!.removeObject(clients[rowIdx])
            sm!.save()
        }
        
        for (var idx = 0; idx < tableView.numberOfRows; idx++){
            if let view = tableView.rowViewAtRow(idx, makeIfNecessary: false)?.viewAtColumn(0) as? EEBSimpleTableCellView {
                view.selected = false
            }
        }
        fetchClients()
        self.tableView.reloadData()
        
    }
    
    override func add(sender : AnyObject){
        if let createdObject = sm!.createObjectOfType(kTVObjectType) as? Client {
            createdObject.name = "New Client"
            createdObject.company = ""
            createdObject.hourlyRate = 90.0
            sm!.save()
        }
        fetchClients()
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
    
    /**
     * @name    showInvoice
     * @brief   Method called when an outstanding invoice button is pressed
     */
    func showInvoice(sender : AnyObject){
        if let view = sender as? NSView ,vc = self.storyboard?.instantiateControllerWithIdentifier("invoiceViewController") as? EEBInvoiceViewController {
            let rowIdx = tableView.rowForView(view)

            let unpaidInvoices = clients[rowIdx].invoices.array.filter({$0.paid == false})
            vc.invoice = unpaidInvoices.first as! Invoice
            vc.navigationController = navigationController            
            navigationController?.pushViewController(vc, true)
        }

    }
    
    /**
     * @name    settings
     * @brief   Show settings for the client
     */
    func settings(sender : AnyObject){
        print("Settings")
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
                vc.client = clients[rowIdx]
            }

            self.navigationController?.pushViewController(vc, true)
            
            //deselect all rows
            for (var idx = 0; idx < tableView.numberOfRows; idx++){
                if let view = tableView.rowViewAtRow(idx, makeIfNecessary: false)?.viewAtColumn(0) as? EEBSimpleTableCellView {
                    view.selected = false
                }
            }
        }
    }
}

