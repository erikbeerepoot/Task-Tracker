//
//  Invoice+CoreDataProperties.swift
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

extension Invoice {
    @NSManaged var dueDate: NSDate?
    @NSManaged var invoiceDate: NSDate?
    @NSManaged var jobs: NSSet?
    @NSManaged var client : Client
    @NSManaged var paid : Bool
    @NSManaged var path : String
    @NSManaged var name : String 

}
