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
        let frame = CGRect(x: 0, y: 0, width: kStatusViewMinWidth,height: kRegularItemHeight)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.didStartTimer(_:)), name: NSNotification.Name(rawValue: kJobTimingSessionDidStartNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.didStopTimer(_:)), name: NSNotification.Name(rawValue: kJobTimingSessionDidStopNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.updateDetailsText(_:)), name: NSNotification.Name(rawValue: kJobDidUpdateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.updateDetailsText(_:)), name: NSNotification.Name(rawValue: kClientDidUpdateNotification), object: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     * @name    viewDidHide
     * @brief   Called when the view hides (such as on minimize)
     */
    override func viewDidHide() {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     * @name    viewDidUnhides
     * @brief   Called when the view unhides (such as restoring window from the dock)
     */
    override func viewDidUnhide() {
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.didStartTimer(_:)), name: NSNotification.Name(rawValue: kJobTimingSessionDidStartNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.didStopTimer(_:)), name: NSNotification.Name(rawValue: kJobTimingSessionDidStopNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.updateDetailsText(_:)), name: NSNotification.Name(rawValue: kJobDidUpdateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EEBStatusView.updateDetailsText(_:)), name: NSNotification.Name(rawValue: kClientDidUpdateNotification), object: nil)

        if(timerRunning){
            progressIndicator?.startAnimation(self)
        }
    }
    
    /**
     * @name    updateDetailsText
     * @brief   Update the details of a job in the status view
     */
    func updateDetailsText(_ notification : Notification){
        if let job = notification.object as? Job {
            leftTextView?.stringValue = "\(job.name) (\(job.client.name!))"
            leftTextView?.needsDisplay = true
        }
    }
    
    func didStartTimer(_ notification : Notification){
        self.progressIndicator?.isHidden = false
        self.progressIndicator?.startAnimation(self)
        rightTextView?.isHidden = false
        timerRunning = true
        
        if let job = notification.object as? Job{
            leftTextView?.stringValue = "\(job.name) (\(job.client.name!))"

            //Recursive closure to keep time updated!
            func updateTimeWrapper(_ job : Job){
                func updateTime(_ job : Job) -> () {
                    rightTextView?.stringValue = job.totalTimeString()
                    rightTextView?.needsDisplay = true
                    
                    if(timerRunning){
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(kUpdateFrequency * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                            updateTime(job)
                        })
                    }
                }
                updateTime(job)
            }
            updateTimeWrapper(job)
        }
    }
    
    
    func didStopTimer(_ notification : Notification){
        self.progressIndicator?.isHidden = true
        self.progressIndicator?.stopAnimation(self)
        timerRunning = false
        
        leftTextView?.stringValue = NSLocalizedString("Timer Stopped", comment: "Timer Stopped")
    }

    func configureLayers(_ frame : CGRect){
        let backgroundLayer = CAGradientLayer()
        let gradientLayer = CAGradientLayer()
        
        /*
         * The background  layer is 1px larger on all sides
         * than the foreground layer. This creates an outline.
         */
        backgroundLayer.frame = frame;

        
        var newFrame = frame
        newFrame.size = CGSize(width: frame.size.width-2, height: frame.size.height-2)
        newFrame.origin = CGPoint(x: frame.origin.x+1,y: frame.origin.y+1)
        gradientLayer.frame = newFrame;
        
        /*
         * To create the appearance of an outline, but stay visually consistent with 
         * the toolbar gradient, we use two grey gradients. One is dark, which creates 
         * the outline, the other is very light grey 
         */
        let outlineStartColour = CGColor(red: kOutlineStartColour,green: kOutlineStartColour,blue: kOutlineStartColour, alpha: 1)
        let outlineEndColour = CGColor(red: kOutlineEndColour,green: kOutlineEndColour,blue: kOutlineEndColour, alpha: 1)
        backgroundLayer.colors = [outlineStartColour,outlineEndColour]
        
        let startColour = CGColor(red: kVeryLightGrayValue,green: kVeryLightGrayValue,blue: kVeryLightGrayValue, alpha: 1)
        let endColour = CGColor(red: kVeryLighterGrayValue, green: kVeryLighterGrayValue, blue: kVeryLighterGrayValue, alpha: 1)
        gradientLayer.colors = [startColour,endColour]
        gradientLayer.autoresizingMask = .layerWidthSizable
        
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
        let piFrame = CGRect(x: self.frame.size.width - kContentItemSize - kPadding, y: self.frame.origin.y + ((self.frame.size.height-kContentItemSize)/2), width: kContentItemSize, height: kContentItemSize)
        progressIndicator = NSProgressIndicator(frame: piFrame)
        progressIndicator?.controlSize = NSControlSize.small
        progressIndicator?.style = NSProgressIndicatorStyle.spinningStyle
        progressIndicator?.isHidden = true
        progressIndicator?.autoresizingMask = .viewMinXMargin
        self.addSubview(progressIndicator!)
    }
    
    func toggleProgress(){
        guard (progressIndicator != nil) else {
            return
        }
        
        //switch state
        if(progressIndicator!.isHidden){
            progressIndicator?.isHidden = false
            progressIndicator?.startAnimation(self)
        } else {
            progressIndicator?.isHidden = true
            progressIndicator?.stopAnimation(self)
        }
    }
    
    func configureLeftJustifiedTextView(_ frame : CGRect){
        var textFieldFrame = frame;
        textFieldFrame.origin.x += kPadding
        textFieldFrame.origin.y -= kInset
        textFieldFrame.size.width = (frame.width - (progressIndicator!.frame.size.width +  kTimeFieldWidth + 2*kPadding))
        
        leftTextView = NSTextField(frame: textFieldFrame)
        leftTextView?.isEditable = false
        leftTextView?.isBordered = false
        leftTextView?.backgroundColor = NSColor.clear
        leftTextView?.font = NSFont(name: "Helvetica Neue Light", size: 12)
        leftTextView?.autoresizingMask = .viewWidthSizable
        self.addSubview(leftTextView!)
    }
    
    
    func configureRightJustifiedTextView(_ frame : CGRect){
        var textFieldFrame = frame;
        textFieldFrame.size.width = kTimeFieldWidth
        textFieldFrame.origin.y -= kInset
        textFieldFrame.origin.x = (progressIndicator?.frame.origin.x)! - (kPadding + textFieldFrame.size.width)
        
        rightTextView = NSTextField(frame: textFieldFrame)
        rightTextView?.isEditable = false
        rightTextView?.isBordered = false
        rightTextView?.backgroundColor = NSColor.clear
        rightTextView?.font = NSFont(name: "Helvetica Neue Light", size: 12)
        rightTextView?.isHidden = true
        rightTextView?.autoresizingMask = .viewMinXMargin
        self.addSubview(rightTextView!)
    }
    
    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
}
