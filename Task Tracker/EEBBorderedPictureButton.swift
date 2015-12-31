//
//  EEBBorderedPictureButton.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-01.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBBorderedPictureButton : NSButton {
    
    let kCornerRadius : CGFloat = 3.0
    let kBorderThickness : CGFloat = 0.25
    
    override var image : NSImage? {
        didSet {
            self.layer?.contents = image
        }
    }
    
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        //turn off default "border"
        self.bordered = false;
        
        //draw custom border & transparent background
        self.layer = CALayer()
        self.layer?.borderColor = NSColor.blackColor().CGColor
        self.layer?.borderWidth = kBorderThickness
        self.layer?.cornerRadius = kCornerRadius
    }
    
    required init?(coder: NSCoder) {
    
        super.init(coder: coder)
        
        //turn off default "border"
        self.bordered = false;
        
        //draw custom border & transparent background
        self.layer = CALayer()
        self.layer?.borderColor = NSColor.blackColor().CGColor
        self.layer?.borderWidth = kBorderThickness
        self.layer?.cornerRadius = kCornerRadius
    }
    
}