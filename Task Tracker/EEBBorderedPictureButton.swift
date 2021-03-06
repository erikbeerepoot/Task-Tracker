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
    
    let cornerRadius : CGFloat = 3.0
    
    var borderThickness : CGFloat = 0.25 {
        didSet {
            layer?.borderWidth = borderThickness
        }
    }
    
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
        layer = CALayer()
        layer?.borderColor = NSColor.blackColor().CGColor
        layer?.borderWidth = borderThickness
        layer?.cornerRadius = cornerRadius
    }
    
    required init?(coder: NSCoder) {
    
        super.init(coder: coder)
        
        //turn off default "border"
        self.bordered = false;
        
        //draw custom border & transparent background
        wantsLayer = true
        layer?.borderColor = NSColor.blackColor().CGColor
        layer?.borderWidth = borderThickness
        layer?.cornerRadius = cornerRadius
    }
    
}