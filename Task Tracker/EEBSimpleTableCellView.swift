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
    case none
    case disclosureIndicator
}

protocol EEBSimpleTableCellViewDelegate {
    func disclosureButtonPressed(_ sender : AnyObject)
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
            ringOutlineLayer?.backgroundColor = ringOutlineColor.cgColor
        }
    }
    
    var selected : Bool = false {
        didSet {
            //draw selection
            outlineView?.layer?.backgroundColor = NSColor.white.cgColor
            if(selected){
                outlineView?.layer?.backgroundColor = NSColor(calibratedRed: kOutlineColourComponents.red, green: kOutlineColourComponents.green, blue: kOutlineColourComponents.blue, alpha: 1.0).cgColor
            }

        }
    }
    
    var accessoryType : EEBSimpleTableCellViewAccessoryType = EEBSimpleTableCellViewAccessoryType.disclosureIndicator
    
    
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

    let kGradientStartColour = CGColor(red: 1, green: 1, blue: 1,alpha: 1.0)
    let kGradientEndColour = CGColor(red: 0.9333, green: 0.9333, blue: 0.9333,alpha: 1.0)

    
    
    //contents
    let kCornerRadius : CGFloat = 3.0
    let kDisclosureImageName : String = "arrow-right-small-black-48"
    
    let debugViews : Bool = false;
    
    //MARK: Designated initializers
    override init(frame frameRect: NSRect) {
        self.headerFrame = CGRect(x: 0,y: 0,width: 0,height: 0)
        self.contentFrame = CGRect(x: 0,y: 0,width: 0,height: 0)
        self.accessoryFrame = CGRect(x: 0,y: 0,width: 0,height: 0)
        
        super.init(frame: frameRect)
        initializeFrames(frame)
        initializeHeaderView()
        initializeContentView()
        initializeAccessoryView(accessoryType)
    }
    
    required init?(coder: NSCoder) {
        headerFrame = CGRect(x: 0,y: 0,width: 0,height: 0)
        contentFrame = CGRect(x: 0,y: 0,width: 0,height: 0)
        accessoryFrame = CGRect(x: 0,y: 0,width: 0,height: 0)
        
        super.init(coder: coder)
        initializeFrames(frame)
        
        
        outlineView = NSView(frame: self.bounds)
        outlineView?.layer = CALayer()

        initializeOutline()
        initializeHeaderView()
        initializeContentView()
        initializeAccessoryView(accessoryType)
        
        contentView!.translatesAutoresizingMaskIntoConstraints = false
        contentView!.leadingAnchor.constraint(equalTo: (headerView?.leadingAnchor)!,constant:headerFrame.size.width + kAccessoryPadding).isActive = true
        contentView!.topAnchor.constraint(equalTo: (headerView?.topAnchor)!).isActive = true
        contentView!.bottomAnchor.constraint(equalTo: (headerView?.bottomAnchor)!).isActive = true
        contentView!.trailingAnchor.constraint(equalTo: (accessoryView?.leadingAnchor)!,constant: -kAccessoryPadding).isActive = true

        let distance = (((contentView?.bounds.size.height)! / 2) - (self.accessoryFrame.height/2))
        accessoryView!.translatesAutoresizingMaskIntoConstraints = false
        accessoryView!.leadingAnchor.constraint(equalTo: self.trailingAnchor,constant:-1*(accessoryFrame.size.width + kAccessoryPadding)).isActive = true
        accessoryView!.topAnchor.constraint(equalTo: contentView!.topAnchor,constant:distance).isActive = true
        accessoryView!.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor,constant:-distance).isActive = true
        accessoryView!.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -kAccessoryPadding).isActive = true
        
        self.layer = CALayer()
        
        if(debugViews){
            self.layer?.backgroundColor = NSColor.black.cgColor
        }
    }
    
    func initializeFrames(_ frameRect : CGRect){
        let ratio = frameRect.size.height / (2*kVerticalPadding + kHeaderSize)
        
        //Scale the row relative to our total frame size
        let verticalPadding = kVerticalPadding * ratio
        let headerPadding = kHeaderPadding * ratio
        let headerSize = kHeaderSize * ratio
        let accessorySize = kAccessorySize * ratio
        let accessoryPadding = kAccessoryPadding * ratio
        
        //header frame is leftmost
        self.headerFrame = CGRect(x: frameRect.origin.x + headerPadding, y: frameRect.origin.y + verticalPadding, width: headerSize, height: headerSize)
        
        //accessory view is rightmost
        self.accessoryFrame = CGRect(x: frameRect.origin.x + frameRect.size.width - (accessoryPadding+accessorySize) , y: frameRect.origin.y + verticalPadding + 0.5*(headerSize - accessorySize), width: accessorySize, height: accessorySize)
        
        //content frame is the middle of the cell
        let contentFrameStart_x = self.headerFrame.origin.x + self.headerFrame.size.width + kAccessoryPadding
        self.contentFrame = CGRect(x: contentFrameStart_x, y: self.headerFrame.origin.y,width: self.accessoryFrame.origin.x - contentFrameStart_x - kAccessoryPadding, height: headerSize)

    }
    
    func initializeOutline(){
        let insetFrame =  NSMakeRect(outlineView!.frame.origin.x + kSelectionOutlineThickness,outlineView!.frame.origin.y + kSelectionOutlineThickness,outlineView!.frame.size.width - 2*kSelectionOutlineThickness,outlineView!.frame.size.height-2*kSelectionOutlineThickness
        )
        let insetView = NSView(frame: insetFrame)
        insetView.layer = CALayer()
        insetView.layer?.backgroundColor = NSColor.white.cgColor
        outlineView!.addSubview(insetView)
        self.addSubview(outlineView!)
        
        outlineView!.translatesAutoresizingMaskIntoConstraints = false
        outlineView!.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        outlineView!.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        outlineView!.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        outlineView!.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        insetView.translatesAutoresizingMaskIntoConstraints = false
        insetView.leadingAnchor.constraint(equalTo: self.outlineView!.leadingAnchor,constant: kSelectionOutlineThickness).isActive = true
        insetView.topAnchor.constraint(equalTo: self.outlineView!.topAnchor, constant: kSelectionOutlineThickness).isActive = true
        insetView.bottomAnchor.constraint(equalTo: self.outlineView!.bottomAnchor , constant: -kSelectionOutlineThickness).isActive = true
        insetView.trailingAnchor.constraint(equalTo: self.outlineView!.trailingAnchor,constant: -kSelectionOutlineThickness).isActive = true

    }
    
    func initializeHeaderView(){
        headerView = NSView(frame: headerFrame)
        
        //configure as layer-hosting view
        headerView?.wantsLayer = true;
        if(debugViews){
            headerView?.layer?.backgroundColor = NSColor.red.cgColor
        }
        
        self.addSubview(headerView!)
        
        drawHeaderOutline()
        imageLayer?.contents = headerImage
    }
    
    func drawHeaderOutline(){
        let frame = CGRect(x: 0, y: 0, width: headerFrame.size.width , height: headerFrame.size.height)

        /*** Outside border ***/
        let ringOutline = CALayer()
        ringOutline.frame = frame
        ringOutline.backgroundColor = lightLightGray.cgColor
        
        let ringOutlineMaskLayer = CAShapeLayer()
        ringOutlineMaskLayer.path = CGPath(ellipseIn: frame.insetBy(dx: 0,dy: 0), transform: nil)
        ringOutline.mask = ringOutlineMaskLayer
        ringOutlineLayer = ringOutline
        
        /*** Inside edge ***/
        let ring = CAGradientLayer()
        ring.frame = frame
        ring.colors = [kGradientStartColour,kGradientEndColour]
        
        let ringMaskLayer = CAShapeLayer()
        ringMaskLayer.path = CGPath(ellipseIn: frame.insetBy(dx: 1.0,dy: 1.0), transform: nil)
        ring.mask = ringMaskLayer

        //mask the inner layer
        let maskLayer = CAShapeLayer()
        maskLayer.path = CGPath(ellipseIn: frame.insetBy(dx: 5,dy: 5), transform: nil)


        /*** Inner border ***/
        let ringInnerBorder = CALayer()
        ringInnerBorder.frame = frame
        ringInnerBorder.backgroundColor = lightLightGray.cgColor
        
        let ringInnerBorderMaskLayer = CAShapeLayer()
        ringInnerBorderMaskLayer.path = CGPath(ellipseIn: frame.insetBy(dx: 7,dy: 7), transform: nil)
        ringInnerBorder.mask = maskLayer

        let ringInnerBorderShadow = CALayer()
        ringInnerBorderShadow.frame = frame
        
        ringInnerBorderShadow.shadowColor = NSColor.darkGray.cgColor
        ringInnerBorderShadow.shadowOpacity = 0.7
        ringInnerBorderShadow.shadowRadius = 7
        ringInnerBorderShadow.shadowPath = CGPath(ellipseIn: frame.insetBy(dx: 4,dy: 4), transform: nil)
        ringInnerBorderShadow.shadowOffset = CGSize(width: 0.0, height: 0.0)
        
        imageLayer = CALayer()
        imageLayer?.borderWidth = kBorderWidth
        imageLayer?.frame = frame
        imageLayer?.shadowColor = NSColor.black.cgColor
        imageLayer?.mask = ringInnerBorderMaskLayer
        imageLayer?.backgroundColor = NSColor.white.cgColor
        
        
        
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
            contentView?.layer?.backgroundColor = NSColor.yellow.cgColor
        }
        self.addSubview(contentView!)
        
    }
    
    func initializeAccessoryView(_ accessoryType : EEBSimpleTableCellViewAccessoryType){
        accessoryView = NSView(frame: accessoryFrame)
        
        switch accessoryType {
        case EEBSimpleTableCellViewAccessoryType.disclosureIndicator:
            /** 
             * We create 3 layers, stacked on top of each other. The root layer is blue, and we overlay
             * an inset white layer to create a 0.5 pt outline. The third layer contains the indicator
             */
            accessoryView?.layer = CALayer()
            accessoryView?.wantsLayer = true;
            accessoryView?.layer?.backgroundColor = CGColor(red: kOutlineColourComponents.red, green: kOutlineColourComponents.green, blue: kOutlineColourComponents.blue, alpha: 1.0)
            accessoryView?.layer?.cornerRadius = kCornerRadius
            
            let backgroundLayer = CALayer()
            backgroundLayer.frame = CGRect(x: 0.5, y: 0.5, width: accessoryFrame.size.width - 1.0 , height: accessoryFrame.size.height - 1.0)
            backgroundLayer.backgroundColor = CGColor(red: kBackgroundColourComponents.red,green: kBackgroundColourComponents.green,blue: kBackgroundColourComponents.blue,alpha: 1.0)
            backgroundLayer.cornerRadius = kCornerRadius
            accessoryView!.layer!.addSublayer(backgroundLayer)
            createDisclosureButton(backgroundLayer.frame)
            
            
        case EEBSimpleTableCellViewAccessoryType.none:
            break;
        }
       
        
        if(debugViews){
            accessoryView?.layer?.backgroundColor = NSColor.blue.cgColor
        }
        
        self.addSubview(accessoryView!)
    }
    
    func createDisclosureButton(_ frame : CGRect){
        //add button
        let disclosureButton = EEBBorderedPictureButton(frame: frame)
        disclosureButton.target = self
        disclosureButton.action = #selector(EEBSimpleTableCellView.disclosureButtonPressed(_:))
        
        let imageLayer = CALayer()
        imageLayer.frame = frame
        imageLayer.contents = getTintedImage(NSImage(named: kDisclosureImageName)!,tint: NSColor(cgColor: (accessoryView?.layer?.backgroundColor!)!)!)
        accessoryView!.addSubview(disclosureButton)
        accessoryView!.layer!.addSublayer(imageLayer)
    }
    
    func getTintedImage(_ image:NSImage, tint:NSColor) -> NSImage {
        
        let tinted = image.copy() as! NSImage
        tinted.lockFocus()
        tint.set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        NSRectFillUsingOperation(imageRect, NSCompositingOperation.sourceAtop)
        
        tinted.unlockFocus()
        return tinted
    }
        
    /** 
     * @name    disclosureButtonPressed
     * @brief   Placeholder for disclosure button delegate method.
     */
    func disclosureButtonPressed(_ sender: AnyObject) {
        delegate?.disclosureButtonPressed(self)
    }
    
}
