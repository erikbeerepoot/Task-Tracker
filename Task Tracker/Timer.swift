//
//  Timer
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-11.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit
class EEBTimer {
    var currentSession : TimingSession? = nil;
    var sm : EEBPersistentStoreManager
    
    var running : Bool {
        return (currentSession != nil)
    }
    
    var job : Job? {
        return currentSession?.job
    }
    
    init(storeManager : EEBPersistentStoreManager){
        sm = storeManager     
    }
    
    /**
     * @name    startTimingSession
     * @brief   Tries to start a new timing session for this job. 
     * @returns true on success, false on failure 
     */
    func startTimingSession(job : Job) -> Bool {
        guard (currentSession == nil) else {
            return false;
        }
        
        //Create new timing session
        if let session = sm.createObjectOfType("TimingSession") as? TimingSession {
            session.startDate = NSDate()
            session.endDate = session.startDate
            currentSession = session
            
            job.addTimingSession(currentSession!)
            NSNotificationCenter.defaultCenter().postNotificationName(kJobTimingSessionDidStartNotification, object: job)
            return true
        }
        return false
    }
    
    /**
     * @name    stopTimingSession
     * @brief   Tries to stop the current timing session
     * @returns true on success, false on failure
     */
    func stopTimingSession() -> Bool {
        if(currentSession != nil){
            currentSession!.endDate = NSDate()
            
            //Remove the last timing session we add (essentially a placeholder)
            let job = currentSession!.job
            job.removeTimingSession(job.sessions.lastObject as! TimingSession)
            job.addTimingSession(currentSession!)
            
            currentSession = nil
            NSNotificationCenter.defaultCenter().postNotificationName(kJobTimingSessionDidStopNotification, object: job)
            return true
        }
        return false;
    }
}