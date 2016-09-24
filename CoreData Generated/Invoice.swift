//
//  Invoice.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-10-27.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import CoreData


class Invoice: NSManagedObject {
    
    class func createInvoiceForClient(_ client : Client,withJobs jobs : [Job], andStoreManager manager : EEBPersistentStoreManager) -> Invoice? {
        let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if let documentDir = dirs.first {
            
            //Invoice parameters
            let invoiceNumber = client.invoices.count
            let fileName = "Invoice-\(invoiceNumber + 1).pdf"

            //Create invoice
            let invoiceCreator = EEBPDFInvoiceCreator(userinfo: client, client: client,jobs: jobs)
            invoiceCreator.createPDF(atPath: documentDir, withFilename: "/" + fileName )
            
            //Add invoice to client
            if let invoice = manager.createObjectOfType("Invoice") as? Invoice {
                invoice.client = client
                invoice.dueDate = Date()
                invoice.invoiceDate = invoice.dueDate
                invoice.paid = false
                invoice.path = documentDir + "/" + fileName
                invoice.name = fileName
                
                client.invoices.add(invoice)
                manager.save()
                return invoice
            }
        }
        return nil
    }
}
