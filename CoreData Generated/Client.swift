//
//  Client.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-27.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import CoreData


class Client: NSManagedObject {

    lazy var formatter : NumberFormatter =  {
        let tempFormatter = NumberFormatter()
        tempFormatter.numberStyle = NumberFormatter.Style.currency
        return tempFormatter
    }()
    
    
    var rateString : String {
        get {
            let rateStr = formatter.string(from: hourlyRate)
            return (rateStr != nil) ? rateStr! : hourlyRate.stringValue
        }
        set {
            let r = formatter.number(from: newValue)
            hourlyRate = (r != nil) ? r! : 0.0
        }
    }    
}
