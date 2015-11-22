//
//  EEBTimingSessionsViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-22.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

protocol EEBTimingSessionsViewControllerDelegate {
    func doneEditing()
}

class EEBTimingSessionsViewController : NSViewController, NSPopoverDelegate, NSTextFieldDelegate,NSTableViewDelegate,NSTableViewDataSource {
    @IBOutlet weak var tableView : NSTableView!
    
    let kDefaultSize : CGFloat = 50.0
    let kTVObjectType = "TimingSession"
    
    let kDateColumnIdentifier = "date"
    let kDurationColumnIdentifier = "duration"
    
    //Module state
    var delegate : EEBTimingSessionsViewControllerDelegate? = nil
    var popover : NSPopover? = nil
    var job : Job? = nil
    var sm : PersistentStoreManager? = nil
    
    override func viewDidLoad() {        
        tableView.backgroundColor = NSColor.clearColor()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if job == nil {
            return 0
        }
        
        return (job!.sessions.count > 0) ? job!.sessions.count : 1
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if(job!.sessions.count==0){
            if tableColumn?.identifier == "duration" {
                return nil
            }
            
            if let cellView = tableView.makeViewWithIdentifier("date", owner: self) as? NSTableCellView {
                cellView.textField?.stringValue = "No sessions"
                cellView.textField?.editable = false
                return cellView
            }
            return nil
        }
        
        let currentSession = job!.sessions[row] as? TimingSession
        switch(tableColumn!.identifier){
            case kDateColumnIdentifier:
                if let cellView = tableView.makeViewWithIdentifier("date", owner: self) as? NSTableCellView {
                    let formatter : NSDateFormatter = NSDateFormatter()
                    formatter.dateStyle = .ShortStyle
                    formatter.locale = NSLocale.currentLocale()
                    cellView.textField?.editable = true
                    cellView.textField?.target = self
                    cellView.textField?.action = Selector("textfieldEdited:")
                    cellView.textField?.stringValue = formatter.stringFromDate(currentSession!.startDate)
                    cellView.layer?.backgroundColor = NSColor.redColor().CGColor
                    return cellView
                }
            case kDurationColumnIdentifier:
                if let cellView = tableView.makeViewWithIdentifier("duration", owner: self) as? NSTableCellView {
                    if let timeInterval = currentSession?.endDate.timeIntervalSinceDate(currentSession!.startDate) as NSTimeInterval? {
                        cellView.textField?.stringValue = NSTimeInterval.timeIntervalToString(timeInterval)
                        cellView.textField?.editable = true
                        cellView.textField?.target = self
                        cellView.textField?.action = Selector("textfieldEdited:")
                    }
                    return cellView
                }
            default:
                return nil

        }
        return nil
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if let view = tableView.rowViewAtRow(row, makeIfNecessary:true) {
            view.backgroundColor = NSColor.redColor()
            return view
        }
        return nil
    }
    
    func textfieldEdited(sender: NSTextField) {
        guard tableView.rowForView(sender) != -1 && tableView.columnForView(sender) != -1 else {
            return
        }
        
        let column = tableView.tableColumns[tableView.columnForView(sender)]
        let session = job!.sessions[tableView.rowForView(sender)] as? TimingSession
        switch column.identifier {
        case kDateColumnIdentifier:
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.locale = NSLocale.currentLocale()
            if let date = formatter.dateFromString(sender.stringValue) {
                session?.startDate = date
            }
            sm?.save()
            return
        case kDurationColumnIdentifier:
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.locale = NSLocale.currentLocale()

            let duration = NSTimeInterval.timeIntervalFromString(sender.stringValue)
            if duration > 0 {
                session?.endDate = session!.startDate.dateByAddingTimeInterval(duration)
                sm?.save()
            }

            return
        default:
            return
        }
    }
    
    @IBAction func add(sender : AnyObject){
        if let createdObject = sm!.createObjectOfType(self.kTVObjectType) as? TimingSession {
            createdObject.startDate = NSDate()
            createdObject.endDate = createdObject.startDate
            job!.addTimingSession(createdObject)
            sm!.save()
        }
        tableView.reloadData()
        
    }
    
    @IBAction func remove(sender : AnyObject){
        guard tableView.selectedRowIndexes.count > 0  else {
            return
        }
        
        let sessionsToRemove = tableView.selectedRowIndexes.map() {job!.sessions[$0] }
        sessionsToRemove.forEach() { sm!.removeObject($0 as! TimingSession)}
        
        sm!.save()
        tableView.reloadData()
    }
    
    @IBAction func done(sender : AnyObject){
        delegate?.doneEditing()
        popover?.close()
    }
    
    func popoverWillClose(notification: NSNotification) {
        delegate?.doneEditing()
    }
    
    override func keyUp(theEvent: NSEvent) {
        if tableView.selectedRowIndexes.count > 0 {
            let deleteKey = String(utf16CodeUnits: [unichar(NSDeleteCharacter)], count: 1) as String

            if let pressedCharacters = theEvent.charactersIgnoringModifiers {
                if (pressedCharacters == deleteKey){
                    remove(self)
                } else if pressedCharacters == "\r" {
                    if tableView.selectedRow == -1 {
                        done(self)
                    } else if tableView.selectedRow == (tableView.numberOfRows-1) {
                        add(self)
                        //
                        tableView.editColumn(0, row: (tableView.numberOfRows-1), withEvent: nil, select: true)
                    }
                }
            }

        }
    }
}