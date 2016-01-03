//
//  Client+CoreDataProperties.swift
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

extension Client {

    @NSManaged var address: String?
    @NSManaged var email: String?
    @NSManaged var company: String
    @NSManaged var hourlyRate: NSNumber
    @NSManaged var name: String?
    @NSManaged var invoices: NSMutableOrderedSet
    @NSManaged var jobs: NSMutableOrderedSet
    @NSManaged var identifier : String?

}
