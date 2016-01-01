//
//  EEBBorderedPictureButton.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-01.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBBorderedColourButton : NSButton {
    
    let kCornerRadius : CGFloat = 3.0
    let kBorderThickness : CGFloat = 0.25
    
    var borderColor =  NSColor(calibratedRed:0.816,green:0.007,blue:0.106,alpha:1.0) {
        didSet {
            self.layer?.borderColor = borderColor.CGColor
        }
    }
    var backgroundColor =  NSColor(calibratedRed:0.988,green:0.835,blue:0.859,alpha:1.0) {
        didSet {
            self.layer?.backgroundColor = backgroundColor.CGColor
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        //turn off default "border"
        self.bordered = false;
        
        //draw custom border & transparent background
        self.layer = CALayer()
        self.layer?.borderColor = borderColor.CGColor
        self.layer?.backgroundColor = backgroundColor.CGColor
        self.layer?.borderWidth = kBorderThickness
        self.layer?.cornerRadius = kCornerRadius
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        //turn off default "border"
        self.bordered = false;
        
        //draw custom border & transparent background
        self.layer = CALayer()
        self.layer?.borderColor = borderColor.CGColor
        self.layer?.backgroundColor = backgroundColor.CGColor
        self.layer?.borderWidth = kBorderThickness
        self.layer?.cornerRadius = kCornerRadius
    }
    
}