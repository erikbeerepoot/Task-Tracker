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
    var invoice : Invoice!
    
    override func viewDidLoad(){
        //Set overlay buttons
        let leftButton = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = #selector(EEBInvoiceViewController.back(_:))
        
        let shareButton = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        shareButton.image = NSImage(named:"share-48")
        shareButton.target = self
        shareButton.action = #selector(EEBInvoiceViewController.share(_:))
        
        overlayView.leftBarButtonItems = [leftButton]
        overlayView.rightBarButtonItems = [shareButton]
        
        customSpacerView.layer = CALayer()
    }
    
    override func viewDidAppear() {
         customSpacerView.layer?.backgroundColor = CGColor(red: overlayView.kGradientStartColour.red, green: overlayView.kGradientStartColour.green, blue: overlayView.kGradientStartColour.blue, alpha: 1.0)
        
        guard invoice != nil else {
            print("No invoice set to display");
            return
        }
        
        let url = URL(string: "file://" + invoice.path)
        let pdfDocument = PDFDocument(url: url!)
        pdfView.document = pdfDocument
    }
    
    //MARK: Overlay actions
    func back(_ sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func share(_ sender : AnyObject){
        //stub
    }

}
