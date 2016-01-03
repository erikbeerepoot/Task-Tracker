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
    var running = false
    
    /************************************************************
     *                      Timing Logic                        *
     ************************************************************/

     /**
     * @name    addTimingSession
     * @brief   Adds a timing session to this job
     */
    func addTimingSession(session : TimingSession) {
        let ses = self.mutableOrderedSetValueForKey("sessions")
        ses.addObject(session)
        sessions = ses
    }
    
    /**
     * @name removeTimingSession
     * @brief removes a timing session from this job
     */
    func removeTimingSession(session : TimingSession) {
        let ses = self.mutableOrderedSetValueForKey("sessions")
        ses.removeObject(session)
        sessions = ses
    }
    
    /**
     * @name       totalTime
     * @brief       Returns the total time of this job as an NSTimeInterval (aka Double)
     */
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

    /**
     * @name totalTimeString
     * @brief Returns the total time of this job as a string
     */
    func totalTimeString() -> String {
        return NSTimeInterval.timeIntervalToString(totalTime())
    }
        
    /************************************************************
     *                      Cost Logic                          *
     ************************************************************/
    
    /**
     * @name    cost
     * @brief   Returns the cost of this job as a string
     */
    func cost() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        let cost = formatter.stringFromNumber(computeCost())
        return (cost == nil) ? "" : cost!
    }
    
    /**
     * @name    computeCost
     * @brief   returns the cost of this job as a Double
     * @note    Due to inheriting from NSObject we can't overload on the return type (boo Obj-C interop)
     */
    func computeCost() -> Double {
        let time = totalTime() as Double
        let r : Double = (rate == nil) ? client.hourlyRate.doubleValue : rate!.doubleValue
        return (r*(time/3600))
    }            
    
}
