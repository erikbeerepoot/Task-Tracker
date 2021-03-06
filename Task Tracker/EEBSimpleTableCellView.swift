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
    
    var imageLayer : CALayer?
    //Subview content settings
    var headerImage : NSImage = NSImage(named: "client128.png")! {
        didSet {
            drawHeaderOutline()
            imageLayer?.contents = headerImage
        }
    }
    
    var ringOutlineLayer : CALayer?
    var ringOutlineColor : NSColor = lightLightGray {
        didSet {
            ringOutlineLayer?.backgroundColor = ringOutlineColor.CGColor
        }
    }
    
    var selected : Bool = false {
        didSet {
            //draw selection
            outlineView?.layer?.backgroundColor = NSColor.whiteColor().CGColor
            if(selected){
                outlineView?.layer?.backgroundColor = NSColor(calibratedRed: kOutlineColourComponents.red, green: kOutlineColourComponents.green, blue: kOutlineColourComponents.blue, alpha: 1.0).CGColor
            }

        }
    }
    
    var accessoryType : EEBSimpleTableCellViewAccessoryType = EEBSimpleTableCellViewAccessoryType.DisclosureIndicator
    
    
    //MARK: Frames
    var headerFrame : CGRect
    var contentFrame : CGRect
    var accessoryFrame : CGRect
    
    //MARK: Appearance constants
    //layout
    let kSelectionOutlineThickness : CGFloat = 2.0
    let kHeaderSize  : CGFloat = 128.0
    let kAccessorySize : CGFloat = 50.0
    let kHeaderPadding : CGFloat = 30.0
    let kVerticalPadding : CGFloat = 20.0
    let kAccessoryPadding : CGFloat = 20.0
    let kBorderWidth : CGFloat = 1
    
    //colours
    let kOutlineColourComponents = (red: CGFloat(0.2902), green : CGFloat(0.5647), blue : CGFloat(0.8863))
    let kBackgroundColourComponents = (red: CGFloat(0.9804), green : CGFloat(0.9804), blue : CGFloat(0.9804))

    let kGradientStartColour = CGColorCreateGenericRGB(1, 1, 1,1.0)
    let kGradientEndColour = CGColorCreateGenericRGB(0.9333, 0.9333, 0.9333,1.0)

    
    
    //contents
    let kCornerRadius : CGFloat = 3.0
    let kDisclosureImageName : String = "arrow-right-small-black-48"
    
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
        
        
        outlineView = NSView(frame: self.bounds)
        outlineView?.layer = CALayer()

        initializeOutline()
        initializeHeaderView()
        initializeContentView()
        initializeAccessoryView(accessoryType)
        
        contentView!.translatesAutoresizingMaskIntoConstraints = false
        contentView!.leadingAnchor.constraintEqualToAnchor(headerView?.leadingAnchor,constant:headerFrame.size.width + kAccessoryPadding).active = true
        contentView!.topAnchor.constraintEqualToAnchor(headerView?.topAnchor).active = true
        contentView!.bottomAnchor.constraintEqualToAnchor(headerView?.bottomAnchor).active = true
        contentView!.trailingAnchor.constraintEqualToAnchor(accessoryView?.leadingAnchor,constant: -kAccessoryPadding).active = true

        let distance = (((contentView?.bounds.size.height)! / 2) - (self.accessoryFrame.height/2))
        accessoryView!.translatesAutoresizingMaskIntoConstraints = false
        accessoryView!.leadingAnchor.constraintEqualToAnchor(self.trailingAnchor,constant:-1*(accessoryFrame.size.width + kAccessoryPadding)).active = true
        accessoryView!.topAnchor.constraintEqualToAnchor(contentView!.topAnchor,constant:distance).active = true
        accessoryView!.bottomAnchor.constraintEqualToAnchor(contentView!.bottomAnchor,constant:-distance).active = true
        accessoryView!.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor,constant: -kAccessoryPadding).active = true
        
        self.layer = CALayer()
        
        if(debugViews){
            self.layer?.backgroundColor = NSColor.blackColor().CGColor
        }
    }
    
    func initializeFrames(frameRect : CGRect){
        let ratio = frameRect.size.height / (2*kVerticalPadding + kHeaderSize)
        
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
    
    func initializeOutline(){
        let insetFrame =  NSMakeRect(outlineView!.frame.origin.x + kSelectionOutlineThickness,outlineView!.frame.origin.y + kSelectionOutlineThickness,outlineView!.frame.size.width - 2*kSelectionOutlineThickness,outlineView!.frame.size.height-2*kSelectionOutlineThickness
        )
        let insetView = NSView(frame: insetFrame)
        insetView.layer = CALayer()
        insetView.layer?.backgroundColor = NSColor.whiteColor().CGColor
        outlineView!.addSubview(insetView)
        self.addSubview(outlineView!)
        
        outlineView!.translatesAutoresizingMaskIntoConstraints = false
        outlineView!.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        outlineView!.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        outlineView!.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        outlineView!.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        
        insetView.translatesAutoresizingMaskIntoConstraints = false
        insetView.leadingAnchor.constraintEqualToAnchor(self.outlineView!.leadingAnchor,constant: kSelectionOutlineThickness).active = true
        insetView.topAnchor.constraintEqualToAnchor(self.outlineView!.topAnchor, constant: kSelectionOutlineThickness).active = true
        insetView.bottomAnchor.constraintEqualToAnchor(self.outlineView!.bottomAnchor , constant: -kSelectionOutlineThickness).active = true
        insetView.trailingAnchor.constraintEqualToAnchor(self.outlineView!.trailingAnchor,constant: -kSelectionOutlineThickness).active = true

    }
    
    func initializeHeaderView(){
        headerView = NSView(frame: headerFrame)
        
        //configure as layer-hosting view
        headerView?.wantsLayer = true;
        if(debugViews){
            headerView?.layer?.backgroundColor = NSColor.redColor().CGColor
        }
        
        self.addSubview(headerView!)
        
        drawHeaderOutline()
        imageLayer?.contents = headerImage
    }
    
    func drawHeaderOutline(){
        let frame = CGRectMake(0, 0, headerFrame.size.width , headerFrame.size.height)

        /*** Outside border ***/
        let ringOutline = CALayer()
        ringOutline.frame = frame
        ringOutline.backgroundColor = lightLightGray.CGColor
        
        let ringOutlineMaskLayer = CAShapeLayer()
        ringOutlineMaskLayer.path = CGPathCreateWithEllipseInRect(CGRectInset(frame,0,0), nil)
        ringOutline.mask = ringOutlineMaskLayer
        ringOutlineLayer = ringOutline
        
        /*** Inside edge ***/
        let ring = CAGradientLayer()
        ring.frame = frame
        ring.colors = [kGradientStartColour,kGradientEndColour]
        
        let ringMaskLayer = CAShapeLayer()
        ringMaskLayer.path = CGPathCreateWithEllipseInRect(CGRectInset(frame,1.0,1.0), nil)
        ring.mask = ringMaskLayer

        //mask the inner layer
        let maskLayer = CAShapeLayer()
        maskLayer.path = CGPathCreateWithEllipseInRect(CGRectInset(frame,5,5), nil)


        /*** Inner border ***/
        let ringInnerBorder = CALayer()
        ringInnerBorder.frame = frame
        ringInnerBorder.backgroundColor = lightLightGray.CGColor
        
        let ringInnerBorderMaskLayer = CAShapeLayer()
        ringInnerBorderMaskLayer.path = CGPathCreateWithEllipseInRect(CGRectInset(frame,7,7), nil)
        ringInnerBorder.mask = maskLayer

        let ringInnerBorderShadow = CALayer()
        ringInnerBorderShadow.frame = frame
        
        ringInnerBorderShadow.shadowColor = NSColor.darkGrayColor().CGColor
        ringInnerBorderShadow.shadowOpacity = 0.7
        ringInnerBorderShadow.shadowRadius = 7
        ringInnerBorderShadow.shadowPath = CGPathCreateWithEllipseInRect(CGRectInset(frame,4,4), nil)
        ringInnerBorderShadow.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        imageLayer = CALayer()
        imageLayer?.borderWidth = kBorderWidth
        imageLayer?.frame = frame
        imageLayer?.shadowColor = NSColor.blackColor().CGColor
        imageLayer?.mask = ringInnerBorderMaskLayer
        imageLayer?.backgroundColor = NSColor.whiteColor().CGColor
        
        
        
        ringOutline.addSublayer(ring)
        ring.addSublayer(ringInnerBorder)
        ringInnerBorder.addSublayer(ringInnerBorderShadow)
        ringInnerBorderShadow.addSublayer(imageLayer!)
        headerView?.layer?.addSublayer(ringOutline)

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
             * an inset white layer to create a 0.5 pt outline. The third layer contains the indicator
             */
            accessoryView?.layer = CALayer()
            accessoryView?.wantsLayer = true;
            accessoryView?.layer?.backgroundColor = CGColorCreateGenericRGB(kOutlineColourComponents.red, kOutlineColourComponents.green, kOutlineColourComponents.blue, 1.0)
            accessoryView?.layer?.cornerRadius = kCornerRadius
            
            let backgroundLayer = CALayer()
            backgroundLayer.frame = CGRectMake(0.5, 0.5, accessoryFrame.size.width - 1.0 , accessoryFrame.size.height - 1.0)
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