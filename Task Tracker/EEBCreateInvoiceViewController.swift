//
//  EEBCreateInvoiceViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2016-01-02.
//  Copyright © 2016 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBCreateInvoiceViewController : NSViewController, NavigableViewController {
    
    /**** Top level views ****/
    @IBOutlet weak var overlayView : EEBOverlayView!
    @IBOutlet weak var customSpacerView : NSView!
    @IBOutlet weak var backgroundView : NSView!

    /**** Create subview ****/
    @IBOutlet weak var createOptionsView : NSView!
    
    //constraint selection
    @IBOutlet weak var chkbtn_selection : NSButton!
    @IBOutlet weak var chkbtn_dataRange : NSButton!
    @IBOutlet weak var chkbtn_expression : NSButton!

    //constraint details
    @IBOutlet weak var fromDatePicker : NSDatePicker!
    @IBOutlet weak var toDatePicker : NSDatePicker!
    @IBOutlet weak var expressionField : NSTextField!
    
    //action buttons
    @IBOutlet weak var openButton : NSButton!
    @IBOutlet weak var createButton : NSButton!

    
    var navigationController : EEBNavigationController? = nil;
    var storeManager : EEBPersistentStoreManager? = nil
        
    override func viewDidLoad(){
        print("Create new invoice")
    }
    
    @IBAction func create(sender : AnyObject){
        
    }

    @IBAction func open(sender : AnyObject){
        
    }
}