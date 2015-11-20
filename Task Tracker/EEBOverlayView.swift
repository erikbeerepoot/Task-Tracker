//
//  EEBOverlayView.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-01.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBOverlayView : NSView {
    
    //MARK: Subview Containers
    var _leftBarButtonItems : [NSButton]? = nil;
    var leftBarButtonItems : [NSButton]? {
        get {
            return _leftBarButtonItems
        }
        set {
            _leftBarButtonItems = newValue
            layoutLeftButtonItems()
        }
    }
    var _rightBarButtonItems : [NSButton]? = nil;
    var rightBarButtonItems : [NSButton]? {
        get {
            return _rightBarButtonItems
        }
        set {
            _rightBarButtonItems = newValue
            layoutRightButtonItems()
        }
    }
    
    var leftItemsView : NSView? = nil;
    var contentView : NSView? = nil;
    var rightItemsView : NSView? = nil;
    
    //MARK: View frames
    var leftItemsFrame : CGRect = CGRectMake(0,0,0,0)
    var contentFrame: CGRect = CGRectMake(0,0,0,0)
    var rightItemsFrame : CGRect = CGRectMake(0,0,0,0)
    
    //MARK: Appearance constants
    //layout
    let kElementPadding : CGFloat = 10.0
    let kLeftPadding : CGFloat = 25.0
    let kRightPadding : CGFloat = 25.0
    let kVerticalPadding : CGFloat = 50.0
    let kElementSize : CGFloat = 32.0
    let debugViews : Bool = false
    
    //MARK: Colours
    let kGradientStartColour = (red: CGFloat(1.0000), green : CGFloat(0.8078), blue : CGFloat(0.1100))
    let kGradientEndColour = (red: CGFloat(0.9804), green : CGFloat(0.8510), blue : CGFloat(0.3804))
    let kContentOpacity : CGFloat = 1
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initializeFrames(frameRect)
        configureLeftItemsView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initializeFrames(self.frame)

        configureLeftItemsView()
        configureContentView()
        configureRightItemsView()
        
        self.layer = CAGradientLayer()
        (self.layer as! CAGradientLayer).colors  = [CGColorCreateGenericRGB(kGradientStartColour.red, kGradientStartColour.green, kGradientStartColour.blue, kContentOpacity),
                                                    CGColorCreateGenericRGB(kGradientEndColour.red, kGradientEndColour.green, kGradientEndColour.blue, kContentOpacity)]
        if(debugViews){
            self.layer?.backgroundColor = NSColor.blackColor().CGColor
        }
        
        let dropShadow = NSShadow()
        dropShadow.shadowColor = NSColor.grayColor()
        dropShadow.shadowOffset = NSMakeSize(0,-4.0)
        dropShadow.shadowBlurRadius = 4.0
        self.shadow = dropShadow
    }
    
    func back(sender : AnyObject){
        NSLog("back")
    }

    
    /**
     * @name    initializeFrames
     * @brief   Initializes the subview frames for 1 item each
     **/    func initializeFrames(frameRect : CGRect){
        //We must have room to show the overlay
        assert(kElementSize <= frameRect.size.height)

        //Keep our UI elements of constant size, and scale the padding
        let verticalPadding = 0.5*(frameRect.size.height - kElementSize)
        
        //header frame is leftmost
        leftItemsFrame = CGRectMake(kLeftPadding,verticalPadding,kElementSize,kElementSize)
        
        //accessory view is rightmost
        rightItemsFrame = CGRectMake(frameRect.size.width - (2*kElementSize + kElementPadding + kRightPadding),verticalPadding, 2*kElementSize + kElementPadding, kElementSize)
        
        //content frame is the middle of the cell
        let contentFrameStart_x = self.leftItemsFrame.origin.x + self.leftItemsFrame.size.width + kLeftPadding
        contentFrame = CGRectMake(contentFrameStart_x, self.leftItemsFrame.origin.y,self.rightItemsFrame.origin.x - contentFrameStart_x - kLeftPadding, kElementSize)
    }
    
    func configureLeftItemsView(){
        leftItemsView = NSView(frame:leftItemsFrame)
        leftItemsView?.layer = CALayer()
        leftItemsView?.wantsLayer = true
        if(debugViews){
            leftItemsView?.layer?.backgroundColor = NSColor.redColor().CGColor
        }
        self.addSubview(leftItemsView!)
    }
    
    func configureContentView(){
        contentView = NSView(frame:contentFrame)
        contentView?.layer = CALayer()
        contentView?.wantsLayer = true
        if(debugViews){
            contentView?.layer?.backgroundColor = NSColor.yellowColor().CGColor
        }
        self.addSubview(contentView!)
    }

    func configureRightItemsView(){
        rightItemsView = NSView(frame:rightItemsFrame)
        rightItemsView?.layer = CALayer()
        rightItemsView?.wantsLayer = true
        
        if(debugViews){
            rightItemsView?.layer?.backgroundColor = NSColor.greenColor().CGColor
        }
        self.addSubview(rightItemsView!)

        rightItemsView?.autoresizingMask = .ViewMinXMargin        
    }
    
    func configureDefaultButtons() {
        //defaut left button
        let leftButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = Selector("back:")
        leftBarButtonItems = [leftButton]

        
        let settingsButton = EEBBorderedPictureButton(frame: CGRectMake(0,0,32,32))
        settingsButton.image = NSImage(named:"settings-48")
        settingsButton.target = self
        settingsButton.action = Selector("settings:")
        
        let invoicesButton = EEBBorderedPictureButton(frame: CGRectMake(32+kElementPadding,0,32,32))
        invoicesButton.image = NSImage(named:"square-inc-cash-48")
        invoicesButton.target = self
        invoicesButton.action = Selector("invoices:")
        
        rightBarButtonItems = [settingsButton,invoicesButton]
        self.rightItemsView?.addSubview(settingsButton)
        self.rightItemsView?.addSubview(invoicesButton)
    }
    
    func layoutLeftButtonItems(){
        
        self.leftItemsView!.addSubview((_leftBarButtonItems?.first)!)
    }
    
    func layoutRightButtonItems(){
        let firstButton = _rightBarButtonItems?.first!
        let secondButton = _rightBarButtonItems?.last!
        
        secondButton?.frame.origin.x = firstButton!.frame.origin.x + kElementSize + kElementPadding
        self.rightItemsView!.addSubview(firstButton!)
        self.rightItemsView!.addSubview(secondButton!)
    }
    
  
    
}