//
//  EEBInvoiceViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-16.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit
import Quartz

class EEBInvoiceViewController : NSViewController,NavigableViewController {
    @IBOutlet weak var overlayView : EEBOverlayView!
    @IBOutlet weak var customSpacerView : NSView!
    @IBOutlet weak var pdfView : PDFView!
    
    var navigationController : EEBNavigationController? = nil
    var storeManager : EEBPersistentStoreManager? = nil
    var invoicePath : String? = nil
    
    override func viewDidLoad(){
        //Set overlay buttons
        let leftButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = Selector("back:")
        
        let shareButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        shareButton.image = NSImage(named:"share-48")
        shareButton.target = self
        shareButton.action = Selector("share:")
        
        overlayView.leftBarButtonItems = [leftButton]
        overlayView.rightBarButtonItems = [shareButton]
        
        customSpacerView.layer = CALayer()
    }
    
    override func viewDidAppear() {
         customSpacerView.layer?.backgroundColor = CGColorCreateGenericRGB(overlayView.kGradientStartColour.red, overlayView.kGradientStartColour.green, overlayView.kGradientStartColour.blue, 1.0)
        
        guard invoicePath != nil else {
            print("Invoice path invalid (nil)")
            return 
        }
        
        let url = NSURL(string: "file://" + invoicePath!)
        let pdfDocument = PDFDocument(URL: url!)
        pdfView.setDocument(pdfDocument)
    }
    
    //MARK: Overlay actions
    func back(sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func share(sender : AnyObject){
        //stub
    }

}