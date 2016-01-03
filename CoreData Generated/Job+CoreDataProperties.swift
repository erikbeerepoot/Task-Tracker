//
//  Job+CoreDataProperties.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-15.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Job {

    @NSManaged var jobDescription: String?
    @NSManaged var name: String
    @NSManaged var rate: NSNumber?
    @NSManaged var sessions: NSOrderedSet
    @NSManaged var client: Client
    @NSManaged var creationDate : NSDate
}
