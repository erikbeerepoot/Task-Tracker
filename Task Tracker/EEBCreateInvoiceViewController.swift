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
    @IBOutlet weak var chkbtn_dateRange : NSButton!
    @IBOutlet weak var chkbtn_expression : NSButton!

    //constraint details
    @IBOutlet weak var fromDatePicker : NSDatePicker!
    @IBOutlet weak var toDatePicker : NSDatePicker!
    @IBOutlet weak var expressionField : NSTextField!
    
    //action buttons
    @IBOutlet weak var openButton : NSButton!
    @IBOutlet weak var createButton : NSButton!

    //MARK: Appearance constants
    let kGradientStartColour = (red: CGFloat(0.208), green : CGFloat(0.208), blue : CGFloat(0.208))
    let kGradientEndColour   = (red: CGFloat(0.356), green : CGFloat(0.356), blue : CGFloat(0.356))
    let kContentOpacity : CGFloat = 1
    let kCornerRadius : CGFloat = 16
    let kBorderWidth : CGFloat = 0.5
    
    
    var navigationController : EEBNavigationController? = nil;
    var storeManager : EEBPersistentStoreManager? = nil
    var client : Client? = nil
    var jobs : [Job]? = nil
    
    override func viewDidLoad(){
        //Set navbar controls
        //Set overlay buttons
        let leftButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = Selector("back:")
        
        overlayView.leftBarButtonItems = [leftButton]
        overlayView.rightBarButtonItems = []
        customSpacerView.layer = CALayer()
        
        
        //Set background colour
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.colors = [CGColorCreateGenericRGB(kGradientStartColour.red, kGradientStartColour.green, kGradientStartColour.blue, kContentOpacity),
        CGColorCreateGenericRGB(kGradientEndColour.red, kGradientEndColour.green, kGradientEndColour.blue, kContentOpacity)]
        backgroundView.layer = bgGradientLayer
        
        //Create outline of options box
        createOptionsView.wantsLayer = true
        createOptionsView.layer?.borderWidth = kBorderWidth
        createOptionsView.layer?.cornerRadius = kCornerRadius
        createOptionsView.layer?.borderColor = NSColor.whiteColor().CGColor
    }
    
    override func viewWillAppear() {
        fromDatePicker.dateValue = NSDate()
        toDatePicker.dateValue = NSDate()
        
    }
    
    @IBAction func create(sender : AnyObject){
        guard client != nil && jobs != nil else {
            print("Client or Jobs is nil")
            return
        }
        
        if let vc = self.storyboard?.instantiateControllerWithIdentifier("invoiceViewController") as? EEBInvoiceViewController {
            vc.navigationController = navigationController
            vc.storeManager = storeManager
            self.navigationController?.pushViewController(vc, true)

            var jobsSubset : [Job] = []
            if(chkbtn_selection.state == NSOnState){
                 jobsSubset = jobs!
            } else {
                if let j = client!.jobs.array as? [Job] {
                    jobsSubset = j
                }
            }
            
            //Create invoice
            let invoiceCreator = EEBPDFInvoiceCreator(userinfo: client!, client: client!,jobs: jobsSubset)
            invoiceCreator.createPDF(atPath: "/Users/erik/Documents/", withFilename: "Invoice.pdf")

            
            
            
        }
    }

    @IBAction func open(sender : AnyObject){
        print("Not implenented yet")
    }
    
    //MARK: Overlay actions
    func back(sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}