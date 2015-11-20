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
    let kStatusViewMinWidth : CGFloat = 310.0
    
    override init(itemIdentifier: String){
        super.init(itemIdentifier: itemIdentifier)
    }
    
    override func awakeFromNib() {
        let frame = CGRectMake(0, 0, kStatusViewMinWidth,kRegularItemHeight)
        
        self.view = EEBStatusView(frame:frame)
        self.view?.frame = frame
        
        self.minSize = (self.view?.frame.size)!
        self.maxSize = (self.view?.frame.size)!
        self.maxSize.width = 1000
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
    let kInset : CGFloat = 2.0
    let kPadding : CGFloat = 5
    let kTimeFieldWidth : CGFloat = 60.0
    let kContentItemSize : CGFloat = 16.0
    
    var leftJustifiedText : String = NSLocalizedString("Timer Stopped", comment: "Timer Stopped")
    var leftTextView : NSTextField? = nil;
    
    var rightJustifiedText : String = "00:00:00"
    var rightTextView : NSTextField? = nil;
    
    var showProgressIndicator : Bool = true;
    var progressIndicator : NSProgressIndicator? = nil;
    var timerRunning = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect)
        
        self.frame = frame;
        
        configureLayers(frame)

        
        if(self.showProgressIndicator){
            setupProgressIndicator()
        }
        configureLeftJustifiedTextView(frame)
        configureRightJustifiedTextView(frame)
                
        leftTextView?.stringValue = leftJustifiedText
        rightTextView?.stringValue = rightJustifiedText
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didStartTimer:"), name: kJobTimingSessionDidStartNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didStopTimer:"), name: kJobTimingSessionDidStopNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateDetailsText:"), name: kJobDidUpdateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateDetailsText:"), name: kClientDidUpdateNotification, object: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidHide() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
//    override func layoutSublayersOfLayer(layer: CALayer) {
//        if let lay = layer.sublayers?.first {
//            lay.frame.size.width = layer.frame.size.width - 2.0
//            
//            //update position of progress indicator and text
//            progressIndicator?.frame = CGRectMake(self.frame.size.width - kContentItemSize - kPadding, self.bounds.origin.y + ((self.frame.size.height-kContentItemSize)/2), kContentItemSize, kContentItemSize)
//            rightTextView!.frame.origin.x = (progressIndicator!.frame.origin.x) - (rightTextView!.bounds.size.width)
//        }
//    }
    
    func updateDetailsText(notification : NSNotification){
        if let job = notification.object as? Job {
            leftTextView?.stringValue = "\(job.name) (\(job.client.name!))"
            leftTextView?.needsDisplay = true
        }
    }
    
    func didStartTimer(notification : NSNotification){
        self.progressIndicator?.hidden = false
        self.progressIndicator?.startAnimation(self)
        rightTextView?.hidden = false
        timerRunning = true
        
        if let job = notification.object as? Job{
            leftTextView?.stringValue = "\(job.name) (\(job.client.name!))"

            //Recursive closure to keep time updated!
            func updateTimeWrapper(job : Job){
                func updateTime(job : Job) -> () {
                    rightTextView?.stringValue = job.totalTimeString()
                    rightTextView?.needsDisplay = true
                    
                    if(timerRunning){
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(kUpdateFrequency * Double(NSEC_PER_SEC))), dispatch_get_main_queue(),{
                            updateTime(job)
                        })
                    }
                }
                updateTime(job)
            }
            updateTimeWrapper(job)
        }
    }
    
    
    func didStopTimer(notification : NSNotification){
        self.progressIndicator?.hidden = true
        self.progressIndicator?.stopAnimation(self)
        timerRunning = false
        
        leftTextView?.stringValue = NSLocalizedString("Timer Stopped", comment: "Timer Stopped")
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
        let outlineStartColour = CGColorCreateGenericRGB(kOutlineStartColour,kOutlineStartColour,kOutlineStartColour, 1)
        let outlineEndColour = CGColorCreateGenericRGB(kOutlineEndColour,kOutlineEndColour,kOutlineEndColour, 1)
        backgroundLayer.colors = [outlineStartColour,outlineEndColour]
        
        let startColour = CGColorCreateGenericRGB(kVeryLightGrayValue,kVeryLightGrayValue,kVeryLightGrayValue, 1)
        let endColour = CGColorCreateGenericRGB(kVeryLighterGrayValue, kVeryLighterGrayValue, kVeryLighterGrayValue, 1)
        gradientLayer.colors = [startColour,endColour]
        gradientLayer.autoresizingMask = .LayerWidthSizable
        
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
        progressIndicator?.controlSize = NSControlSize.SmallControlSize
        progressIndicator?.style = NSProgressIndicatorStyle.SpinningStyle
        progressIndicator?.hidden = true
        self.addSubview(progressIndicator!)
    }
    
    func toggleProgress(){
        guard (progressIndicator != nil) else {
            return
        }
        
        //switch state
        if(progressIndicator!.hidden){
            progressIndicator?.hidden = false
            progressIndicator?.startAnimation(self)
        } else {
            progressIndicator?.hidden = true
            progressIndicator?.stopAnimation(self)
        }
    }
    
    func configureLeftJustifiedTextView(frame : CGRect){
        var textFieldFrame = frame;
        textFieldFrame.origin.x += kPadding
        textFieldFrame.origin.y -= kInset
        textFieldFrame.size.width = (frame.width - (progressIndicator!.frame.size.width +  kTimeFieldWidth + 2*kPadding))
        
        leftTextView = NSTextField(frame: textFieldFrame)
        leftTextView?.editable = false
        leftTextView?.bordered = false
        leftTextView?.backgroundColor = NSColor.clearColor()
        leftTextView?.font = NSFont(name: "Helvetica Neue Light", size: 12)
        self.addSubview(leftTextView!)
    }
    
    
    func configureRightJustifiedTextView(frame : CGRect){
        var textFieldFrame = frame;
        textFieldFrame.size.width = kTimeFieldWidth
        textFieldFrame.origin.y -= kInset
        textFieldFrame.origin.x = (progressIndicator?.frame.origin.x)! - (kPadding + textFieldFrame.size.width)
        
        rightTextView = NSTextField(frame: textFieldFrame)
        rightTextView?.editable = false
        rightTextView?.bordered = false
        rightTextView?.backgroundColor = NSColor.clearColor()
        rightTextView?.font = NSFont(name: "Helvetica Neue Light", size: 12)
        rightTextView?.hidden = true
        self.addSubview(rightTextView!)
    }
    
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
}