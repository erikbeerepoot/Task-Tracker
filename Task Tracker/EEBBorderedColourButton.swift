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
    let kBorderThickness : CGFloat = 0.1
    
    let backgroundLayer = CALayer()
    let outlineLayer = CALayer()
    var textfield : NSTextField? = nil
    
    var borderColor =  NSColor(calibratedRed:0.816,green:0.007,blue:0.106,alpha:1.0) {
        didSet {
            outlineLayer.backgroundColor = borderColor.cgColor
            outlineLayer.setNeedsDisplay()
        }
    }
    var backgroundColor =  NSColor(calibratedRed:0.988,green:0.835,blue:0.859,alpha:1.0) {
        didSet {
            backgroundLayer.backgroundColor = backgroundColor.cgColor
            backgroundLayer.setNeedsDisplay()
        }
    }
    
    var text : String = "" {
        didSet {
            textfield?.stringValue = text
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        bounds = frame
        
        //turn off default "border"
        self.isBordered = false;
        self.wantsLayer = true
        
        //draw custom border & transparent background
        outlineLayer.frame = frameRect
        outlineLayer.backgroundColor = borderColor.cgColor
        outlineLayer.cornerRadius = kCornerRadius

        backgroundLayer.frame.origin.x = frameRect.origin.x + 0.5
        backgroundLayer.frame.origin.y = frameRect.origin.y + 0.5
        backgroundLayer.frame.size.width = frameRect.size.width - 1
        backgroundLayer.frame.size.height = frameRect.size.height - 1
        backgroundLayer.backgroundColor = NSColor.clear.cgColor
        backgroundLayer.cornerRadius = kCornerRadius
        
        textfield = NSTextField(frame: frameRect)
        textfield!.frame.origin.y -= 2
        textfield!.isBezeled = false
        textfield!.isEditable = false
        textfield!.drawsBackground = false
        textfield!.alignment = .center
        textfield!.font = NSFont(name: "Helvetica Neue Light", size: 12.0)
        textfield!.textColor = NSColor.darkGray
        
        addSubview(textfield!)
        layer?.addSublayer(outlineLayer)
        layer?.addSublayer(backgroundLayer)
        layer?.cornerRadius = kCornerRadius
    }
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        
        bounds = frame
        
        //turn off default "border"
        self.isBordered = false;
        self.wantsLayer = true
        
        //draw custom border & transparent background
        outlineLayer.frame = frame
        outlineLayer.backgroundColor = borderColor.cgColor
        outlineLayer.cornerRadius = kCornerRadius
        
        backgroundLayer.frame.origin.x = frame.origin.x + 0.5
        backgroundLayer.frame.origin.y = frame.origin.y + 0.5
        backgroundLayer.frame.size.width = frame.size.width - 1
        backgroundLayer.frame.size.height = frame.size.height - 1
        backgroundLayer.backgroundColor = backgroundColor.cgColor
        backgroundLayer.cornerRadius = kCornerRadius
        
        textfield = NSTextField(frame: frame)
        textfield!.frame.origin.y -= 2
        textfield!.isBezeled = false
        textfield!.isEditable = false
        textfield!.drawsBackground = false
        textfield!.alignment = .center
        textfield!.font = NSFont(name: "Helvetica Neue Light", size: 12.0)
        textfield!.textColor = NSColor.darkGray
        
        addSubview(textfield!)
        layer?.addSublayer(outlineLayer)
        layer?.addSublayer(backgroundLayer)
        layer?.cornerRadius = kCornerRadius
        
        layer?.addSublayer(outlineLayer)
        layer?.addSublayer(backgroundLayer)
        layer?.cornerRadius = kCornerRadius
    }
    
}
