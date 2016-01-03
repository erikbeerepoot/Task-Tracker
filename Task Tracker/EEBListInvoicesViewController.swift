//
//  EEBListInvoicesViewController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2016-01-03.
//  Copyright © 2016 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBListInvoicesViewController : NSViewController, NavigableViewController, NSTableViewDataSource {
    
    /**** Top level views ****/
    @IBOutlet weak var overlayView : EEBOverlayView!
    @IBOutlet weak var customSpacerView : NSView!
    @IBOutlet weak var backgroundView : NSView!
    @IBOutlet weak var tableView : NSTableView!
    
    //MARK: Appearance constants
    let kGradientStartColour = (red: CGFloat(0.208), green : CGFloat(0.208), blue : CGFloat(0.208))
    let kGradientEndColour   = (red: CGFloat(0.356), green : CGFloat(0.356), blue : CGFloat(0.356))
    let kContentOpacity : CGFloat = 1
    let kCornerRadius : CGFloat = 16
    let kBorderWidth : CGFloat = 0.75

    
    var navigationController : EEBNavigationController? = nil;
    var storeManager : EEBPersistentStoreManager? = nil
    var client : Client? = nil
    var invoices : [Invoice] = []
    
    @IBAction func open(sender : AnyObject){
        print("Not implemented yet")
    }
    
    override func viewDidLoad() {
        guard client != nil else {
            return
        }
        
        if let inv = client!.invoices.array as? [Invoice] {
            invoices = inv
        }
        
        //Set navbar controls
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
        
    }
    
    //MARK: Overlay actions
    func back(sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return invoices.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return invoices[row]
    }

}
