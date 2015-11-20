//
//  EEBInvoiceViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-16.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBInvoiceViewController : NSViewController,NavigableViewController {
    @IBOutlet weak var overlayView : EEBOverlayView!
    @IBOutlet weak var customSpacerView : NSView!
    
    var navigationController : EEBNavigationController? = nil
    var storeManager : PersistentStoreManager? = nil

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
    }
    
    //MARK: Overlay actions
    func back(sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func share(sender : AnyObject){
        //stub
    }

}