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
    @IBOutlet weak var listInvoicesBackgroundView : NSView!
    @IBOutlet weak var tableView : NSTableView!
    
    //MARK: Appearance constants
    let kGradientStartColour = (red: CGFloat(0.208), green : CGFloat(0.208), blue : CGFloat(0.208))
    let kGradientEndColour   = (red: CGFloat(0.356), green : CGFloat(0.356), blue : CGFloat(0.356))
    let kContentOpacity : CGFloat = 1
    let kCornerRadius : CGFloat = 16
    let kBorderWidth : CGFloat = 0.75
    let debugFrames = false
    
    var navigationController : EEBNavigationController? = nil;
    var storeManager : EEBPersistentStoreManager? = nil
    var client : Client? = nil
    var invoices : [Invoice] = []
    
    override func viewDidLoad() {
        guard client != nil else {
            return
        }
        
        if let inv = client!.invoices.array as? [Invoice] {
            invoices = inv
        }
        
        
        /*** View Constraints ***/
        listInvoicesBackgroundView.wantsLayer = true
        if(debugFrames){
            listInvoicesBackgroundView.layer?.backgroundColor = NSColor.yellow.cgColor
        }
        
        
        tableView.dataSource = self
        
        //Set navbar controls
        let leftButton = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = #selector(EEBListInvoicesViewController.back(_:))
        
        overlayView.leftBarButtonItems = [leftButton]
        overlayView.rightBarButtonItems = []
        customSpacerView.layer = CALayer()
        
        //Set background colour
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.colors = [CGColor(red: kGradientStartColour.red, green: kGradientStartColour.green, blue: kGradientStartColour.blue, alpha: kContentOpacity),
            CGColor(red: kGradientEndColour.red, green: kGradientEndColour.green, blue: kGradientEndColour.blue, alpha: kContentOpacity)]
        backgroundView.layer = bgGradientLayer
        
        //Create outline of options box
        listInvoicesBackgroundView.wantsLayer = true
        listInvoicesBackgroundView.layer?.borderWidth = kBorderWidth
        listInvoicesBackgroundView.layer?.cornerRadius = kCornerRadius
        listInvoicesBackgroundView.layer?.borderColor = NSColor.white.cgColor
    }
    
    
    //MARK: Overlay actions
    func back(_ sender : AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return invoices.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return invoices[row].name
    }

    @IBAction func open(_ sender : AnyObject){
        if let vc = self.storyboard?.instantiateController(withIdentifier: "invoiceViewController") as? EEBInvoiceViewController {
            vc.navigationController = navigationController
            vc.storeManager = storeManager
            vc.invoice = invoices[tableView.selectedRow]
            
            self.navigationController?.pushViewController(vc, true)
        }
    }

    
}
