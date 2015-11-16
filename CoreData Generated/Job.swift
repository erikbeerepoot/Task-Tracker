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
        let ses = self.mutableOrderedSetValueForKey("sessions")
        ses.addObject(session)
        sessions = ses
    }
    
    func removeTimingSession(session : TimingSession) {
        let ses = self.mutableOrderedSetValueForKey("sessions")
        ses.removeObject(session)
        sessions = ses
    }
    
    func totalTime() -> NSTimeInterval {
        var time : NSTimeInterval = 0
        if let nativeSpecializedSet = sessions.set as?  Set<TimingSession>{
            time = nativeSpecializedSet.reduce(0) { $0 + ($1.endDate).timeIntervalSinceDate($1.startDate)}
        }
        
        //If we haven't stopped the last sessions yet, we need to compare against the current time
        if let lastSession = sessions.lastObject as? TimingSession {
            if(lastSession.startDate == lastSession.endDate){
               time += NSDate().timeIntervalSinceDate(lastSession.startDate)
            }
        }        
        return time
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
        return (r*(time/3600))
    }
    
    
        
    
}
