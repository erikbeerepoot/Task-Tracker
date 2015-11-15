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
    var sm : PersistentStoreManager? = nil
    var kTVObjectType = ""
    var navigationController : EEBNavigationController? = nil;
    var allowSelection = false;
    var timerRunning = false;
    
    //MARK: Appearance constants
    let kIconHeader : String! = "iconHeader"
    let kNameHeader : String! = "nameHeader"
    let kIconView : String! = "iconView"
    let kNameView : String! = "nameView"
    
    var lastSelectedRowIndex : Int = -1 
    
    var selectedObject : AnyObject? {
        let idx = self.tableView.selectedRow
        if(idx == -1 ){
            return nil
        }
                
        if self is EEBJobViewController{
            let jobs = Array((self as! EEBJobViewController).client!.jobs)
            return (jobs.count > idx) ? jobs[idx] : nil
        } else if self is EEBClientViewController {
            return (sm?.allObjectsOfType(kTVObjectType) != nil) ? sm?.allObjectsOfType(kTVObjectType)![idx] : nil
        }
        return nil
    }
    
    override func viewWillAppear() {
        self.backgroundView.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
    
    override func viewDidAppear() {
        self.allowSelection = true;
    }
    
    override func viewWillDisappear() {
        sm?.save()
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func textfieldEdited(sender : NSTextField){
        let rowIdx = tableView.rowForView(sender)
        if(rowIdx != -1){
            let obj = sm?.allObjectsOfType(self.kTVObjectType)?[rowIdx]
            obj?.setValue(sender.stringValue, forKey: sender.identifier!)
            
            if(obj is Client){
                if let jobsArray = (obj as! Client).jobs.allObjects as?  Array<Job>{
                    let newJobs = jobsArray.map({
                        (let job) -> Job  in
                        job.client = (obj as! Client)
                        return job
                    })
                    (obj as! Client).jobs = NSMutableSet(array: newJobs)
                }
            }
            if(obj is Job){
                NSNotificationCenter.defaultCenter().postNotificationName(kJobDidUpdateNotification, object: obj as! Job)
            }
        }
    }
    
    //MARK: TableView methods
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return kRowHeight
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (sm?.allObjectsOfType(kTVObjectType) != nil) ? sm!.allObjectsOfType(kTVObjectType)!.count : 0
    }
    
    @IBAction func add(sender : AnyObject){
        
    }
    
    @IBAction func remove(sender : AnyObject){
        
    }

}