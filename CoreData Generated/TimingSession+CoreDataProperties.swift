//
//  TimingSession+CoreDataProperties.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-27.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TimingSession {

    @NSManaged var startDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var job : Job

}
