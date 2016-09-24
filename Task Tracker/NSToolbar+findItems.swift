//
//  NSToolbar+findItems.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-22.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

extension NSToolbar {
    func itemWithIdentifier(_ identifier : String) -> NSToolbarItem? {
        let items = self.items.filter({ ($0.itemIdentifier == identifier)})
        return items.first
    }
}
