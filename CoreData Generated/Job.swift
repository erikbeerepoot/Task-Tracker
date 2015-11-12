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

}
