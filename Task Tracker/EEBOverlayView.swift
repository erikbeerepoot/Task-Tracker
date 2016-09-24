//
//  EEBOverlayView.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-01.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    var text : String = "" {
        didSet {
            overlayTextField?.stringValue = text
        }
        
    }
    
    var leftItemsView : NSView? = nil;
    var contentView : NSView? = nil;
    var rightItemsView : NSView? = nil;
    var overlayTextField : NSTextField? = nil;
    
    //MARK: View frames
    var leftItemsFrame : CGRect = CGRect(x: 0,y: 0,width: 0,height: 0)
    var contentFrame: CGRect = CGRect(x: 0,y: 0,width: 0,height: 0)
    var rightItemsFrame : CGRect = CGRect(x: 0,y: 0,width: 0,height: 0)
    
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
        
        contentView!.translatesAutoresizingMaskIntoConstraints = false
        contentView!.leadingAnchor.constraint(equalTo: (leftItemsView?.trailingAnchor)!,constant: kLeftPadding).isActive = true
        contentView!.topAnchor.constraint(equalTo: (leftItemsView?.topAnchor)!).isActive = true
        contentView!.bottomAnchor.constraint(equalTo: (leftItemsView?.bottomAnchor)!).isActive = true
        contentView!.trailingAnchor.constraint(equalTo: (rightItemsView?.leadingAnchor)!,constant: -kLeftPadding).isActive = true
        
        overlayTextField!.setContentHuggingPriority(NSLayoutPriority(1), for: NSLayoutConstraintOrientation.horizontal)
        
        overlayTextField!.translatesAutoresizingMaskIntoConstraints = false
        overlayTextField!.leadingAnchor.constraint(equalTo: (contentView?.leadingAnchor)!).isActive = true
        overlayTextField!.topAnchor.constraint(equalTo: (contentView?.topAnchor)!).isActive = true
        overlayTextField!.bottomAnchor.constraint(equalTo: (contentView?.bottomAnchor)!).isActive = true
        overlayTextField!.trailingAnchor.constraint(equalTo: (contentView?.trailingAnchor)!).isActive = true

        
        layer = CAGradientLayer()
        (layer as! CAGradientLayer).colors  = [CGColor(red: kGradientStartColour.red, green: kGradientStartColour.green, blue: kGradientStartColour.blue, alpha: kContentOpacity),
                                                    CGColor(red: kGradientEndColour.red, green: kGradientEndColour.green, blue: kGradientEndColour.blue, alpha: kContentOpacity)]
        if(debugViews){
            self.layer?.backgroundColor = NSColor.black.cgColor
        }
        
        let dropShadow = NSShadow()
        dropShadow.shadowColor = NSColor.gray
        dropShadow.shadowOffset = NSMakeSize(0,-4.0)
        dropShadow.shadowBlurRadius = 4.0
        self.shadow = dropShadow
    }
    
    func back(_ sender : AnyObject){
        NSLog("back")
    }

    
    
    
    
    /**
     * @name    initializeFrames
     * @brief   Initializes the subview frames for 1 item each
     **/    func initializeFrames(_ frameRect : CGRect){
        //We must have room to show the overlay
        assert(kElementSize <= frameRect.size.height)

        //Keep our UI elements of constant size, and scale the padding
        let verticalPadding = 0.5*(frameRect.size.height - kElementSize)
        
        //header frame is leftmost
        leftItemsFrame = CGRect(x: kLeftPadding,y: verticalPadding,width: kElementSize,height: kElementSize)
        
        //accessory view is rightmost
        rightItemsFrame = CGRect(x: frameRect.size.width - (2*kElementSize + kElementPadding + kRightPadding),y: verticalPadding, width: 2*kElementSize + kElementPadding, height: kElementSize)
        
        //content frame is the middle of the cell
        let contentFrameStart_x = self.leftItemsFrame.origin.x + self.leftItemsFrame.size.width + kLeftPadding
        contentFrame = CGRect(x: contentFrameStart_x, y: self.leftItemsFrame.origin.y,width: self.rightItemsFrame.origin.x - contentFrameStart_x - kLeftPadding, height: kElementSize)
    }
    
    func configureLeftItemsView(){
        leftItemsView = NSView(frame:leftItemsFrame)
        leftItemsView?.layer = CALayer()
        leftItemsView?.wantsLayer = true
        if(debugViews){
            leftItemsView?.layer?.backgroundColor = NSColor.red.cgColor
        }
        self.addSubview(leftItemsView!)
    }
    
    func configureContentView(){
        contentView = NSView(frame:contentFrame)
        contentView?.layer = CALayer()
        contentView?.wantsLayer = true
        if(debugViews){
            contentView?.layer?.backgroundColor = NSColor.yellow.cgColor
        }
        self.addSubview(contentView!)
        
        overlayTextField = NSTextField(frame: contentView!.frame)
        overlayTextField!.font = NSFont(name: "Helvetica Neue Light", size: 25.0)
        overlayTextField!.alignment = .center
        overlayTextField!.backgroundColor = NSColor.clear
        overlayTextField!.isBordered = false
        overlayTextField!.focusRingType = .none
        overlayTextField!.isSelectable = false
        overlayTextField!.isEditable = false
        self.addSubview(overlayTextField!)
    }

    func configureRightItemsView(){
        rightItemsView = NSView(frame:rightItemsFrame)
        rightItemsView?.layer = CALayer()
        rightItemsView?.wantsLayer = true
        
        if(debugViews){
            rightItemsView?.layer?.backgroundColor = NSColor.green.cgColor
        }
        self.addSubview(rightItemsView!)

        rightItemsView?.autoresizingMask = .viewMinXMargin
    }
    
    func configureDefaultButtons() {
        //defaut left button
        let leftButton = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        leftButton.image = NSImage(named:"arrow-left-black-48")
        leftButton.target = self
        leftButton.action = #selector(EEBOverlayView.back(_:))
        leftBarButtonItems = [leftButton]

        
        let settingsButton = EEBBorderedPictureButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        settingsButton.image = NSImage(named:"settings-48")
        settingsButton.target = self
        settingsButton.action = Selector("settings:")
        
        let invoicesButton = EEBBorderedPictureButton(frame: CGRect(x: 32+kElementPadding,y: 0,width: 32,height: 32))
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
        guard (_rightBarButtonItems?.count > 0) else {
            NSLog("Skipping right nav bar button layout")
            return
        }
        
        let firstButton = _rightBarButtonItems?.first!
        let secondButton = _rightBarButtonItems?.last!
        
        secondButton?.frame.origin.x = firstButton!.frame.origin.x + kElementSize + kElementPadding
        self.rightItemsView!.addSubview(firstButton!)
        self.rightItemsView!.addSubview(secondButton!)
    }
    
  
    
}
