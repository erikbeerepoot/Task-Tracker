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
    var sm : EEBPersistentStoreManager? = nil
    
    override func viewDidLoad() {        
        tableView.backgroundColor = NSColor.clear
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if job == nil {
            return 0
        }
        
        return (job!.sessions.count > 0) ? job!.sessions.count : 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if(job!.sessions.count==0){
            if tableColumn?.identifier == "duration" {
                return nil
            }
            
            if let cellView = tableView.make(withIdentifier: "date", owner: self) as? NSTableCellView {
                cellView.textField?.stringValue = NSLocalizedString("No sessions", comment: "No sessions")
                cellView.textField?.textColor = NSColor.gray
                cellView.textField?.isEditable = false
                return cellView
            }
            return nil
        }
        
        let currentSession = job!.sessions[row] as? TimingSession
        switch(tableColumn!.identifier){
            case kDateColumnIdentifier:
                if let cellView = tableView.make(withIdentifier: "date", owner: self) as? NSTableCellView {
                    let formatter : DateFormatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.locale = Locale.current
                    cellView.textField?.isEditable = true
                    cellView.textField?.target = self
                    cellView.textField?.action = #selector(EEBTimingSessionsViewController.textfieldEdited(_:))
                    cellView.textField?.stringValue = formatter.string(from: currentSession!.startDate as Date)
                    cellView.textField?.textColor = NSColor.black
                    cellView.layer?.backgroundColor = NSColor.red.cgColor
                    return cellView
                }
            case kDurationColumnIdentifier:
                if let cellView = tableView.make(withIdentifier: "duration", owner: self) as? NSTableCellView {
                    if let timeInterval = currentSession?.endDate.timeIntervalSince(currentSession!.startDate as Date) as TimeInterval? {
                        cellView.textField?.stringValue = TimeInterval.timeIntervalToString(timeInterval)
                        cellView.textField?.isEditable = true
                        cellView.textField?.target = self
                        cellView.textField?.action = #selector(EEBTimingSessionsViewController.textfieldEdited(_:))
                    }
                    return cellView
                }
            default:
                return nil

        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if let view = tableView.rowView(atRow: row, makeIfNecessary:true) {
            view.backgroundColor = NSColor.red
            return view
        }
        return nil
    }
    
    func textfieldEdited(_ sender: NSTextField) {
        guard tableView.row(for: sender) != -1 && tableView.column(for: sender) != -1 else {
            return
        }
        
        let column = tableView.tableColumns[tableView.column(for: sender)]
        let session = job!.sessions[tableView.row(for: sender)] as? TimingSession
        switch column.identifier {
        case kDateColumnIdentifier:
            let formatter : DateFormatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.locale = Locale.current
            if let date = formatter.date(from: sender.stringValue) {
                let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                let dateComponents = (cal as NSCalendar).components([.day , .month, .year ], from: date)
                let timeComponents = (cal as NSCalendar).components([.hour,.minute,.second], from: session!.startDate as Date)

                if let newDate = cal.date(from: dateComponents) {
                    if let finalDate = (cal as NSCalendar).date(byAdding: timeComponents, to: newDate, options: NSCalendar.Options(rawValue:0)){
                        session?.startDate = finalDate
                    }
                }
            

            }
            sm?.save()
            return
        case kDurationColumnIdentifier:
            let formatter : DateFormatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.locale = Locale.current

            let duration = TimeInterval.timeIntervalFromString(sender.stringValue)
            if duration > 0 {
                session?.endDate = session!.startDate.addingTimeInterval(duration)
                sm?.save()
            }

            return
        default:
            return
        }
    }
    
    @IBAction func add(_ sender : AnyObject){
        if let createdObject = sm!.createObjectOfType(self.kTVObjectType) as? TimingSession {
            createdObject.startDate = Date()
            createdObject.endDate = createdObject.startDate
            job!.addTimingSession(session: createdObject)
            sm!.save()
        }
        tableView.reloadData()
        
    }
    
    @IBAction func remove(_ sender : AnyObject){
        guard tableView.selectedRowIndexes.count > 0  else {
            return
        }
        
        let sessionsToRemove = tableView.selectedRowIndexes.map() {job!.sessions[$0] }
        sessionsToRemove.forEach() { sm!.removeObject($0 as! TimingSession)}
        
        sm!.save()
        tableView.reloadData()
    }
    
    @IBAction func done(_ sender : AnyObject){
        delegate?.doneEditing()
        popover?.close()
    }
    
    func undo(_ sender : AnyObject){
        sm!.managedObjectContext?.undoManager?.undo()
        tableView.reloadData()
    }
    
    func redo(_ sender : AnyObject){
        sm!.managedObjectContext?.undoManager?.redo()
        tableView.reloadData()
    }
    
    func popoverWillClose(_ notification: Notification) {
        delegate?.doneEditing()
    }
    
    override func keyUp(with theEvent: NSEvent) {
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
                        tableView.editColumn(0, row: (tableView.numberOfRows-1), with: nil, select: true)
                    }
                }
            }

        }
    }
}
