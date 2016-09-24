//
//  NSTimerInterval+String.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-22.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation

extension TimeInterval {
    static func timeIntervalToString(_ timeInterval : TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [NSCalendar.Unit.hour , NSCalendar.Unit.minute, NSCalendar.Unit.second]
        let string = formatter.string(from: timeInterval)
        return string!
    }
    
    static func timeIntervalFromString(_ string : String) -> TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        if let date = formatter.date(from: string),let referenceDate = formatter.date(from: "00:00:00") {
            return date.timeIntervalSince(referenceDate)
        }
        return -1.0
    }
}
