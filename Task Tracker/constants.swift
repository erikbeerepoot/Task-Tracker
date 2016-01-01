//
//  constants.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-11.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

let kJobTimingSessionDidStartNotification = "JobTimingSessionDidStartNotification"
let kJobTimingSessionDidStopNotification = "JobTimingSessionDidStopNotification"
let kJobDidUpdateNotification = "JobDidUpdateNotification"
let kClientDidUpdateNotification = "ClientDidUpdateNotification"

let kToolbarItemIdentifierRun = "runToolbarItem"
let kToolbarItemIdentifierDelete = "deleteToolbarItem"
let kToolbarItemIdentifierAdd = "addToolbarItem"
let kUpdateFrequency : NSTimeInterval = 1.0


/** Button appearance **/
let kOutstandingInvoicesButtonBorderColor = NSColor(calibratedRed:0.816,green:0.007,blue:0.106,alpha:1.0)
let kOutstandingInvoicesButtonBackgroundColor = NSColor(calibratedRed:0.988,green:0.835,blue:0.859,alpha:1.0)

let kNumJobsButtonBorderColor = NSColor(calibratedRed:0.608,green:0.608,blue:0.608,alpha:1.0)
let kNumJobsButtonBackgroundColor = NSColor(calibratedRed:0.608,green:0.608,blue:0.608,alpha:0.14)