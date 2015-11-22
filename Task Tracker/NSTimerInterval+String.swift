//
//  NSTimerInterval+String.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-22.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    static func timeIntervalToString(timeInterval : NSTimeInterval) -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = [NSCalendarUnit.Hour , NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let string = formatter.stringFromTimeInterval(timeInterval)
        return string!
    }
    
    static func timeIntervalFromString(string : String) -> NSTimeInterval {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        if let date = formatter.dateFromString(string),referenceDate = formatter.dateFromString("00:00:00") {
            return date.timeIntervalSinceDate(referenceDate)
        }
        return -1.0
    }
}