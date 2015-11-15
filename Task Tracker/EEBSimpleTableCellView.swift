//
//  EEBTableCellView.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-31.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

enum EEBSimpleTableCellViewAccessoryType : Int {
    case None
    case DisclosureIndicator
}

protocol EEBSimpleTableCellViewDelegate {
    func disclosureButtonPressed(sender : AnyObject)
}

class EEBSimpleTableCellView : NSTableCellView,EEBSimpleTableCellViewDelegate {
    
    var _delegate : EEBSimpleTableCellViewDelegate? = nil
    var delegate : EEBSimpleTableCellViewDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
            createDisclosureButton(accessoryView!.frame)
        }
    }
    
    //MARK: Subviews
    var outlineView : NSView? = nil;
    var headerView : NSView? = nil;
    var contentView : NSView? = nil;
    var accessoryView : NSView? = nil;
    
    //Subview content settings
    var _headerImage : NSImage? = nil;
    var headerImage : NSImage?  {
        get {
            return _headerImage
        }
        set {
            _headerImage = newValue

            drawHeaderOutline()
            headerView?.layer?.sublayers![0].contents = _headerImage
        }
    }
    
    var accessoryType : EEBSimpleTableCellViewAccessoryType = EEBSimpleTableCellViewAccessoryType.DisclosureIndicator
    
    
    //MARK: Frames
    var headerFrame : CGRect
    var contentFrame : CGRect
    var accessoryFrame : CGRect
    
    //MARK: Appearance constants
    //layout
    let kHeaderPadding : CGFloat = 50.0
    let kHeaderSize  : CGFloat = 128.0
    let kAccessoryPadding : CGFloat = 30.0
    let kAccessorySize : CGFloat = 50.0
    let kVerticalPadding : CGFloat = 50.0
    
    //colours
    let kOutlineColourComponents = (red: CGFloat(0.2902), green : CGFloat(0.5647), blue : CGFloat(0.8863))
    let kBackgroundColourComponents = (red: CGFloat(0.9804), green : CGFloat(0.9804), blue : CGFloat(0.9804))
    
    //contents
    let kCornerRadius : CGFloat = 3.0
    let kDisclosureImageName : String = "arrow-right-black-48"
    
    let debugViews : Bool = false;
    
    //MARK: Designated initializers
    override init(frame frameRect: NSRect) {
        self.headerFrame = CGRectMake(0,0,0,0)
        self.contentFrame = CGRectMake(0,0,0,0)
        self.accessoryFrame = CGRectMake(0,0,0,0)
        
        super.init(frame: frameRect)
        initializeFrames(frame)
        initializeHeaderView()
        initializeContentView()
        initializeAccessoryView(accessoryType)
    }
    
    required init?(coder: NSCoder) {
        headerFrame = CGRectMake(0,0,0,0)
        contentFrame = CGRectMake(0,0,0,0)
        accessoryFrame = CGRectMake(0,0,0,0)
        
        super.init(coder: coder)
        initializeFrames(frame)
        initializeHeaderView()
        initializeContentView()
        initializeAccessoryView(accessoryType)
        
        self.layer = CALayer()
        
        if(debugViews){
            self.layer?.backgroundColor = NSColor.blackColor().CGColor
        }
    }
    
    func initializeFrames(frameRect : CGRect){
        let ratio = frameRect.size.height / (2*kHeaderPadding + kHeaderSize)
        
        //Scale the row relative to our total frame size
        let verticalPadding = kVerticalPadding * ratio
        let headerPadding = kHeaderPadding * ratio
        let headerSize = kHeaderSize * ratio
        let accessorySize = kAccessorySize * ratio
        let accessoryPadding = kAccessoryPadding * ratio
        
        //header frame is leftmost
        self.headerFrame = CGRectMake(frameRect.origin.x + headerPadding, frameRect.origin.y + verticalPadding, headerSize, headerSize)
        
        //accessory view is rightmost
        self.accessoryFrame = CGRectMake(frameRect.origin.x + frameRect.size.width - (accessoryPadding+accessorySize) , frameRect.origin.y + verticalPadding + 0.5*(headerSize - accessorySize), accessorySize, accessorySize)
        
        //content frame is the middle of the cell
        let contentFrameStart_x = self.headerFrame.origin.x + self.headerFrame.size.width + kAccessoryPadding
        self.contentFrame = CGRectMake(contentFrameStart_x, self.headerFrame.origin.y,self.accessoryFrame.origin.x - contentFrameStart_x - kAccessoryPadding, headerSize)

    }
    
    func initializeHeaderView(){
        headerView = NSView(frame: headerFrame)
        
        //configure as layer-hosting view
        headerView?.layer = CALayer()
        headerView?.wantsLayer = true;
        if(debugViews){
            headerView?.layer?.backgroundColor = NSColor.redColor().CGColor
        }
        
        self.addSubview(headerView!)
    }
    
    func drawHeaderOutline(){
        let backgroundLayer = CALayer()
        backgroundLayer.frame = CGRectMake(1.0, 1.0, headerFrame.size.width - 2.0 , headerFrame.size.height - 2.0)
        backgroundLayer.backgroundColor = CGColorCreateGenericRGB(kBackgroundColourComponents.red,kBackgroundColourComponents.green,kBackgroundColourComponents.blue,1.0)
        headerView?.layer?.backgroundColor = NSColor.lightGrayColor().CGColor
        headerView?.layer?.addSublayer(backgroundLayer)
    }
    
    func initializeContentView(){
        contentView = NSView(frame: contentFrame)
        
        contentView?.layer = CALayer()
        contentView?.wantsLayer = true
        if(debugViews){
            contentView?.layer?.backgroundColor = NSColor.yellowColor().CGColor
        }
        
        self.addSubview(contentView!)
    }
    
    func initializeAccessoryView(accessoryType : EEBSimpleTableCellViewAccessoryType){
        accessoryView = NSView(frame: accessoryFrame)
        
        switch accessoryType {
        case EEBSimpleTableCellViewAccessoryType.DisclosureIndicator:
            /** 
             * We create 3 layers, stacked on top of each other. The root layer is blue, and we overlay
             * an inset white layer to create a single pixel outline. The third layer contains the indicator
             */
            accessoryView?.layer = CALayer()
            accessoryView?.wantsLayer = true;
            accessoryView?.layer?.backgroundColor = CGColorCreateGenericRGB(kOutlineColourComponents.red, kOutlineColourComponents.green, kOutlineColourComponents.blue, 1.0)
            accessoryView?.layer?.cornerRadius = kCornerRadius
            
            let backgroundLayer = CALayer()
            backgroundLayer.frame = CGRectMake(1.0, 1.0, accessoryFrame.size.width - 2.0 , accessoryFrame.size.height - 2.0)
            backgroundLayer.backgroundColor = CGColorCreateGenericRGB(kBackgroundColourComponents.red,kBackgroundColourComponents.green,kBackgroundColourComponents.blue,1.0)
            backgroundLayer.cornerRadius = kCornerRadius
            accessoryView!.layer!.addSublayer(backgroundLayer)
            
            createDisclosureButton(backgroundLayer.frame)
            
            
        case EEBSimpleTableCellViewAccessoryType.None:
            break;
        }
       
        
        if(debugViews){
            accessoryView?.layer?.backgroundColor = NSColor.blueColor().CGColor
        }
        
        self.addSubview(accessoryView!)
    }
    
    func createDisclosureButton(frame : CGRect){
        //add button
        let disclosureButton = EEBBorderedPictureButton(frame: frame)
        disclosureButton.target = self
        disclosureButton.action = Selector("disclosureButtonPressed:")
        
        let imageLayer = CALayer()
        imageLayer.frame = frame
        imageLayer.contents = getTintedImage(NSImage(named: kDisclosureImageName)!,tint: NSColor(CGColor: (accessoryView?.layer?.backgroundColor!)!)!)
        accessoryView!.addSubview(disclosureButton)
        accessoryView!.layer!.addSublayer(imageLayer)
    }
    
    func getTintedImage(image:NSImage, tint:NSColor) -> NSImage {
        
        let tinted = image.copy() as! NSImage
        tinted.lockFocus()
        tint.set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        NSRectFillUsingOperation(imageRect, NSCompositingOperation.CompositeSourceAtop)
        
        tinted.unlockFocus()
        return tinted
    }
        
    /** 
     * @name    disclosureButtonPressed
     * @brief   Placeholder for disclosure button delegate method.
     */
    func disclosureButtonPressed(sender: AnyObject) {
        delegate?.disclosureButtonPressed(self)
    }
    
}