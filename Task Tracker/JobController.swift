//
//  JobController.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-11.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation

class JobController {
    var currentSession : TimingSession? = nil;
    var sm : PersistentStoreManager
    
    init(storeManager : PersistentStoreManager){
        sm = storeManager
    }
    
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
            session.endDate = session.startDate
            currentSession = session
            
            job.addTimingSession(currentSession!)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kJobTimingSessionDidStartNotification, object: job)
    }
    
    func stopTimingSession(job : Job){
        if(currentSession != nil){
            currentSession!.endDate = NSDate()
            
            //Remove the last timing session we add (essentially a placeholder)
            job.removeTimingSession(job.sessions.lastObject as! TimingSession)
            job.addTimingSession(currentSession!)
            
            currentSession = nil
        }
        NSNotificationCenter.defaultCenter().postNotificationName(kJobTimingSessionDidStopNotification, object: job)        
    }
}