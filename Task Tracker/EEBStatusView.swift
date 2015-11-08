//
//  EEBStatusView.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-29.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBStatusToolbarItem : NSToolbarItem {

    let kRegularItemHeight : CGFloat = 28.0
    let kStatusViewWidth : CGFloat = 310.0
    
    override init(itemIdentifier: String){
        super.init(itemIdentifier: itemIdentifier)
    }
    
    override func awakeFromNib() {
        let frame = CGRectMake(0, 0, kStatusViewWidth,kRegularItemHeight)
        
        self.view = EEBStatusView(frame:frame)
        self.view?.frame = frame
        
        self.minSize = (self.view?.frame.size)!
        self.maxSize = (self.view?.frame.size)!
    }
    
    override func validate() {
    }
}

class EEBStatusView : NSView {
    
    //Appearance parameters
    let kVeryLightGrayValue : CGFloat = 0.9020;
    let kVeryLighterGrayValue : CGFloat = 0.9569;
    let kOutlineStartColour : CGFloat = 0.6392
    let kOutlineEndColour : CGFloat = 0.8196
    let kCornerRadius : CGFloat = 3.0;
    let kContentItemSize : CGFloat = 16
    let kPadding : CGFloat = 5
    
    var leftJustifiedText : String = "Client : Job"
    var leftTextView : NSTextView? = nil;
    
    var rightJustifiedText : String = "02:11:01"
    var rightTextView : NSTextView? = nil;
    
    var showProgressIndicator : Bool = true;
    var progressIndicator : NSProgressIndicator? = nil;
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        
        self.frame = frame;
        
        configureLayers(frame)

        
        if(self.showProgressIndicator){
            setupProgressIndicator()
        }
        configureLeftJustifiedTextView(frame)
        configureRightJustifiedTextView(frame)
        
        leftTextView?.insertText(leftJustifiedText)
        rightTextView?.insertText(rightJustifiedText)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configureLayers(frame : CGRect){
        let backgroundLayer = CAGradientLayer()
        let gradientLayer = CAGradientLayer()
        
        /*
         * The background  layer is 1px larger on all sides
         * than the foreground layer. This creates an outline.
         */
        backgroundLayer.frame = frame;
        var newFrame = frame
        newFrame.size = CGSizeMake(frame.size.width-2, frame.size.height-2)
        newFrame.origin = CGPointMake(frame.origin.x+1,frame.origin.y+1)
        gradientLayer.frame = newFrame;
        
        
        /*
         * To create the appearance of an outline, but stay visually consistent with 
         * the toolbar gradient, we use two grey gradients. One is dark, which creates 
         * the outline, the other is very light grey 
         */
        let outlineSColour = CGColorCreateGenericRGB(kOutlineStartColour,kOutlineStartColour,kOutlineStartColour, 1)
        let outlineEColour = CGColorCreateGenericRGB(kOutlineEndColour,kOutlineEndColour,kOutlineEndColour, 1)
        backgroundLayer.colors = [outlineSColour,outlineEColour]
        
        let startColour = CGColorCreateGenericRGB(kVeryLightGrayValue,kVeryLightGrayValue,kVeryLightGrayValue, 1)
        let endColour = CGColorCreateGenericRGB(kVeryLighterGrayValue, kVeryLighterGrayValue, kVeryLighterGrayValue, 1)
        gradientLayer.colors = [startColour,endColour]
        
        //Finally, round the corners
        gradientLayer.cornerRadius = kCornerRadius
        backgroundLayer.cornerRadius = kCornerRadius
        
        /*
         * Note that the root layer is the background layer.
         * Also note that 'self.wantsLayer' is last. This makes
         * this view layer hosting, rather than layer backed 
         */
        backgroundLayer.addSublayer(gradientLayer)
        self.layer = backgroundLayer
        self.wantsLayer = true;
    }
    
    //TODO: These methods are really ugly. Fixme
    func setupProgressIndicator(){
        let piFrame = CGRectMake(self.frame.size.width - kContentItemSize - kPadding, self.frame.origin.y + ((self.frame.size.height-kContentItemSize)/2), kContentItemSize, kContentItemSize)
        progressIndicator = NSProgressIndicator(frame: piFrame)
        progressIndicator?.style = NSProgressIndicatorStyle.SpinningStyle
        progressIndicator?.startAnimation(self)
        self.addSubview(progressIndicator!)
    }
    
    func configureLeftJustifiedTextView(frame : CGRect){
        var textViewFrame = frame;
        textViewFrame.origin.x += kPadding
        textViewFrame.size.width -= (frame.width / 2)
        textViewFrame.origin.y += ((frame.size.height-kContentItemSize)/2)
        textViewFrame.size.height = kContentItemSize
        
        leftTextView = NSTextView(frame: textViewFrame)
        leftTextView?.backgroundColor = NSColor.clearColor()
        leftTextView?.font = NSFont(name: "Helvetica Neue Light", size: 12)
        self.addSubview(leftTextView!)
    }
    
    
    func configureRightJustifiedTextView(frame : CGRect){
        var textViewFrame = frame;
        textViewFrame.size.width = 70
        textViewFrame.origin.x += (progressIndicator?.frame.origin.x)! - kPadding - textViewFrame.size.width
        textViewFrame.origin.y += ((frame.size.height-kContentItemSize)/2)
        textViewFrame.size.height = kContentItemSize
        
        rightTextView = NSTextView(frame: textViewFrame)
        rightTextView?.backgroundColor = NSColor.clearColor()
        rightTextView?.font = NSFont(name: "Helvetica Neue Light", size: 12)
        self.addSubview(rightTextView!)
    }
    
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
}