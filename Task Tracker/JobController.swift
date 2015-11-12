//
//  JobController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-11.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation

class JobController : NSObject {
    let sm = PresistentStoreManager()
    var currentSession : TimingSession? = nil;
    
    
    func toggleSession(job : Job) -> Bool {
        if(currentSession==nil){
            startTimingSession(job)
            return true
        } else {
            stopTimingSession(job)
            return false
        }
    }
    
    func startTimingSession(job : Job){
        guard (currentSession == nil) else {
            return;
        }
        
        //Create new timing session
        if let session = sm.createObjectOfType("TimingSession") as? TimingSession {
            session.startDate = NSDate()
            session.endDate = NSDate()
            currentSession = session
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kJobTimingSessionDidStartNotification, object: job)
    }
    
    func stopTimingSession(job : Job){
        if(currentSession != nil){
            currentSession!.endDate = NSDate()
            job.addTimingSession(currentSession!)
            currentSession = nil
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kJobTimingSessionDidStopNotification, object: job)
        
    }
}