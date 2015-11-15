//
//  Job.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-27.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import CoreData


class Job: NSManagedObject {

    func addTimingSession(session : TimingSession) {
        let sessions = self.mutableSetValueForKey("sessions");
        sessions.addObject(session)
    }
    
    func removeTimingSession(session : TimingSession) {
        let sessions = self.mutableSetValueForKey("sessions");
        sessions.removeObject(session)
    }

    func totalTime() -> NSTimeInterval {
        if let nativeSpecializedSet = sessions as? Set<TimingSession>{
            return nativeSpecializedSet.reduce(0) { ($1.endDate).timeIntervalSinceDate($1.startDate)}
        }
        return 0
    }
    
    //Since this swift class is objective-c interop, can't just overload on the return type :(
    func totalTimeString() -> String {
        return Job.timeIntervalToString(totalTime())
    }
    
    func cost() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        let cost = formatter.stringFromNumber(computeCost())
        return (cost == nil) ? "" : cost!
    }
    
    private class func timeIntervalToString(timeInterval : NSTimeInterval) -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = [NSCalendarUnit.Hour , NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let string = formatter.stringFromTimeInterval(timeInterval)
        return (string == nil) ? "" : string!
    }
    
    private func computeCost() -> Double {
        let time = totalTime() as Double
        let r : Double = (rate == nil) ? client.hourlyRate.doubleValue : rate!.doubleValue
        return (r*time)
    }
    
    
        
    
}
