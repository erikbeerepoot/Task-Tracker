//
//  EEBPDFInvoiceCreator.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-23.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBPDFInvoiceCreator {
    
    //Size constants
    let Format_A4_72DPI = CGSize(width:595,height:842)
    let margin_H = CGFloat(40.0)
    let margin_V = CGFloat(40.0)
    
    //Appearance constants
    let kHeaderHeight = CGFloat(20)
    let kHeaderWidth = CGFloat(75)
    let kRowHeight = CGFloat(20)
    let kColWidth = CGFloat(50)
    let kTextInset = CGFloat(2)
    
    
    //Metadata for PDF
    var metadata : Dictionary<String,String> = Dictionary<String,String>()
    
    
    let user : Client, client : Client;
    let jobs : [Job]
    
    init(userinfo : Client, client : Client, jobs : [Job]){
        self.user = userinfo
        self.client = client
        self.jobs = jobs
        
    }
    
    func setMetadata(_ userinfo : Client, client : Client){
        metadata[String(kCGPDFContextTitle)] = NSLocalizedString("Invoice",comment: "Invoice")
        metadata[String(kCGPDFContextCreator)] = userinfo.name
        
    }
        
    func createPDF(atPath path : String, withFilename filename : String) -> Bool {
        
        let template = EEBInvoiceTemplate(templateName: "Basic")
        
        //Attempt to create PDF context
        let path = CFStringCreateWithCString(nil, path+filename, CFStringBuiltInEncodings.UTF8.rawValue);
        let url = CFURLCreateWithFileSystemPath(nil,path,CFURLPathStyle.cfurlposixPathStyle,false)
        guard let writeContext = CGContext(url!, mediaBox: nil, metadata as CFDictionary?) else {
            print("Failed to create PDF context at URL \(url)")
            return false
        }

        var mediaBox: CGRect = CGRect(x: 0, y: 0, width: Format_A4_72DPI.width, height: Format_A4_72DPI.height)

        writeContext.beginPage(mediaBox: &mediaBox)

        let textTransform = CGAffineTransform.identity
        writeContext.textMatrix = textTransform
        
        drawInvoiceHeader(writeContext,template:template,forClient:user, andUser:client)
        drawInvoiceBody(writeContext, template:template,withJobs:jobs)
        drawInvoiceFooter(writeContext,template: template)
        
        writeContext.endPage()
        writeContext.closePDF()
        return true
    }

    
    //MARK: Helpers
    
    
    /** 
     * @name    setupTextBox
     * @brief   Creates a new path (a text box) from the given rectangle
     */
    func setupTextBox(_ x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat) -> CGMutablePath{
        let origin = CGPoint(x:self.margin_H,y:self.margin_V)
        
        let path = CGMutablePath()
        path.addRect(CGRect(x: origin.x + x + 2*kTextInset, y: origin.y + y + kTextInset, width: width - 3*kTextInset, height: height))
        return path
    }
    
    func setupTextBox(inRect rect : CGRect) -> CGMutablePath{
        let path = CGMutablePath()
        path.addRect(CGRect(x: rect.origin.x + 2*kTextInset,y: rect.origin.y - kTextInset, width: rect.size.width -  3*kTextInset, height: rect.size.height))        
        return path
    }
    
    

    /**
     * @name    drawText
     * @brief   Draws the given string on the given path
     * @notes   Changes colour settings (stroke,fill) of context
     */
    func drawText(_ context : CGContext,text : String, path : CGMutablePath, font : NSFont = NSFont.systemFont(ofSize: NSFont.systemFontSize()),alignment : CTTextAlignment = .left){
       
        var attributes = [String : AnyObject]()
        attributes[NSFontAttributeName] = font
        
        //Set alignment
        var alignmentVar : CTTextAlignment = alignment
        let alignmentSetting = [CTParagraphStyleSetting(spec: .alignment , valueSize: MemoryLayout.size(ofValue: alignmentVar), value: &alignmentVar)]
        let paragraphStyle = CTParagraphStyleCreate(alignmentSetting,1)
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        
        
        drawText(context, text: text, path: path, attributes: attributes)
    }
    
    
    func drawText(_ context : CGContext,text : String, path : CGMutablePath, attributes : [String : AnyObject]){
        context.saveGState();
        
        //Create attributed version of the string & draw
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0),text as CFString!);
        
        attributes.forEach({CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), $0.0 as CFString!,$0.1)})
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString!);
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
        CTFrameDraw(frame, context);
        
        context.restoreGState();
    }
    
    /**
     * @name    drawTable
     * @brief   Draws a table inside the given rectangle
     */
    func drawTable(_ context : CGContext,
               inRect rect : CGRect,
                   numRows : Int,
                   numCols : Int,
                rowHeaders : [String] = [],
                colHeaders : [String] = [],
           drawRowDividers : Bool = true,
           drawColDividers : Bool = true,
                 textColor : NSColor = NSColor.white,
               strokeColor : NSColor = NSColor.black,
                 fillColor : NSColor = NSColor.black){
                    
        
                    
        guard (rowHeaders.count == 0 || rowHeaders.count == numRows) &&
            (colHeaders.count == 0 || colHeaders.count == numCols) else {
                return
        }
                    
        //Before we change any context properties, we save the state
        context.saveGState();
        context.setStrokeColor(strokeColor.cgColor.components!)
        context.setFillColor(fillColor.cgColor.components!)
                    
        //Create bounding box
        context.stroke(rect)
        
        //Set header text style
        let font = NSFont(name: "Helvetica Neue", size: 14.0)
        var attributes = [String : AnyObject]()
        attributes[NSFontAttributeName] = font!
        attributes[NSForegroundColorAttributeName] = textColor
        
        var horizontalOffset : CGFloat = 0
        if(rowHeaders.count > 0){
            horizontalOffset = kHeaderWidth
        }
                    
                    
        //If we were given column headers, draw them
        let headerWidth : CGFloat = ((rect.size.width - horizontalOffset) / CGFloat(numCols))
        var colHeaderRect = CGRect(x: rect.origin.x + horizontalOffset, y: rect.origin.y + rect.size.height - kHeaderHeight, width: headerWidth, height: kHeaderHeight)
        for colHeader in colHeaders {
            //fill the header with the appropriate colour
            context.fill(colHeaderRect)
            
            //Create header text
            let textPath = setupTextBox(inRect: colHeaderRect)
            drawText(context, text: colHeader, path: textPath, attributes: attributes)
            
            //next header starts where this one ends
            colHeaderRect.origin.x += headerWidth
        }
             
                    
        //If we were given row headers, draw them
        var rowHeaderRect = CGRect(x: rect.origin.x, y: rect.origin.y + rect.size.height - kHeaderHeight, width: kHeaderWidth, height: kRowHeight)
        for rowHeader in rowHeaders {
            //fill the header with the appropriate colour
            context.fill(rowHeaderRect)
            
            //Create header text
            let textPath = setupTextBox(inRect: rowHeaderRect)
            drawText(context, text: rowHeader, path: textPath, attributes: attributes)
            
            //next header starts where this one ends
            rowHeaderRect.origin.y -= kRowHeight
        }
                    
        //Draw the table inside dividers
        let origin : CGPoint = CGPoint(x: rect.origin.x + horizontalOffset, y: colHeaderRect.origin.y - (colHeaders.count > 0 ? kHeaderHeight : 0))
        let xs = stride(from: origin.x, to: (origin.x + CGFloat(numCols)*headerWidth), by: headerWidth)
        let ys = stride(from: origin.y, to: rect.origin.y, by: -kRowHeight)
                print(ys)
        context.setLineWidth(0.25)

        if(drawColDividers){
            xs.forEach(){context.stroke(CGRect(x: $0,y: colHeaderRect.origin.y,width: headerWidth,height: kHeaderHeight-rect.size.height))}
        }
                    
        if(drawRowDividers){
            ys.forEach(){context.stroke(CGRect(x: origin.x,y: $0,width: rect.size.width-horizontalOffset,height: kRowHeight))}
        }
                    
        context.restoreGState();
    }
    
    /**
     * @name    createInvoiceHeader
     * @brief   Creates the header for the invoice (company info, title, etc)
     */
    func drawInvoiceHeader(_ writeContext : CGContext, template : EEBInvoiceTemplate, forClient client : Client, andUser user : Client){


        /***** Draw document title *****/
        var frame = template.titleBounds
        var path = setupTextBox(inRect:frame)
        var text = "Invoice"
        var font = (template.style["title"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue Bold", size: 25.0)
        drawText(writeContext,text:text, path: path,font:font!)

        
        /************* Dates ***************/
        let formatter : DateFormatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale.current

        
        //Invoice date
        font = (template.style["title-dates"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue", size: 14.0)
        
        frame.origin.y -= 30
        path = setupTextBox(inRect:frame)
        text = "Invoice date: \t \(formatter.string(from: Date()))"
        drawText(writeContext,text:text, path: path,font:font!)

        //Due date
        frame.origin.y -= 20
        path = setupTextBox(inRect:frame)
        text = "Due date: \t \t \(formatter.string(from: Date().addingTimeInterval(1210000)))"
        drawText(writeContext,text:text, path: path,font:font!)            
        
        /****** Draw to & from box ******/
        font = (template.style["to"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue", size: 14.0)
        drawTable(writeContext, inRect:template.toBounds, numRows: 5, numCols: 1,colHeaders:["To:"],drawRowDividers:false)
        path = setupTextBox(inRect:CGRect(x: template.toBounds.origin.x,y: template.toBounds.origin.y - kRowHeight,width: template.toBounds.size.width,height: template.toBounds.size.height))
        text = client.name! + "\n" + client.company
        drawText(writeContext,text:text, path: path,font:font!)

        font = (template.style["to"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue", size: 14.0)
        drawTable(writeContext, inRect:template.fromBounds, numRows: 5, numCols: 1,colHeaders:["From:"],drawRowDividers:false)
        path = setupTextBox(inRect:CGRect(x: template.fromBounds.origin.x,y: template.fromBounds.origin.y - kRowHeight,width: template.fromBounds.size.width,height: template.fromBounds.size.height))
        text = user.name! + "\n" + user.company
        drawText(writeContext,text:text, path: path,font:font!)
    }
    


    
    func drawInvoiceBody(_ writeContext : CGContext, template : EEBInvoiceTemplate, withJobs jobs : [Job]) -> Int{
            let columnNames : [String] = ["Job:","Quantity:","Rate:","Cost:"]
        
        //The max number of jobs that can fit on this page
        let pageJobCount = Int(((template.bodyRect.size.height - kHeaderHeight) / kRowHeight))

        //If we have more jobs than we can fit, fill this page to start
        var numJobsToDraw = jobs.count
        if(jobs.count > pageJobCount){
            numJobsToDraw = pageJobCount
        }
        
        drawTable(writeContext, inRect:template.bodyRect,numRows:numJobsToDraw,numCols:columnNames.count,colHeaders:columnNames)

        let frame = CGRect(x: template.bodyRect.origin.x, y: template.bodyRect.origin.y + template.bodyRect.size.height - kRowHeight, width: template.bodyRect.size.width, height: template.bodyRect.size.height)
        let columnWidth = template.bodyRect.size.width / CGFloat(columnNames.count)
        for jobIdx in 0 ..< jobs.count {
            var currentFrame = CGRect(x: frame.origin.x,y: frame.origin.y - kRowHeight - CGFloat(jobIdx)*kRowHeight,width: columnWidth,height: kRowHeight)
            
            //draw text
            let job = jobs[jobIdx]
            
            var path = setupTextBox(inRect:currentFrame)
            drawText(writeContext, text: " \(job.name)", path: path)
            
            currentFrame.origin.x += columnWidth
            path = setupTextBox(inRect:currentFrame)
            drawText(writeContext, text: " \(job.totalTimeString())", path: path,alignment: .right)
            
            currentFrame.origin.x += columnWidth
            path = setupTextBox(inRect:currentFrame)
            var rate = client.hourlyRate
            if(job.rate != nil && job.rate!.doubleValue > 0.0){
                rate = job.rate!
            }
            
            drawText(writeContext, text: " \(String(format: "$%02.2f",Float(rate)))", path: path,alignment: .right)

            currentFrame.origin.x += columnWidth
            path = setupTextBox(inRect:currentFrame)
            drawText(writeContext, text: " \(job.cost())", path: path,alignment: .right)
        }
    
        
        
        //Totals headers
        var subTotalRect = CGRect(x: template.bodyRect.origin.x + (template.bodyRect.size.width / 2), y: template.bodyRect.origin.y - 3*kRowHeight , width: (template.bodyRect.size.width / 2), height: 3*kRowHeight)
        drawTable(writeContext,inRect: subTotalRect, numRows:3,numCols:1,rowHeaders: ["Subtotal:","Tax:","Total:"],fillColor:NSColor.darkGray)
        
        //Compute totals and display
        let tax = Double(0.15)
        let subTotal = jobs.reduce(0, { $0 + $1.computeCost() })
        let total = subTotal + subTotal*tax

        subTotalRect.origin.x += kHeaderWidth
        subTotalRect.origin.y += 2*kRowHeight
        subTotalRect.size.height = kRowHeight
        subTotalRect.size.width -= kHeaderWidth
        
        //Subtotal
        var path = setupTextBox(inRect:subTotalRect)
        drawText(writeContext, text:" \(String(format: "$%02.2f",Float(subTotal)))", path: path,alignment: .right)
        
        //Tax
        subTotalRect.origin.y -= kRowHeight
        path = setupTextBox(inRect:subTotalRect)
        drawText(writeContext, text:" \(String(format: "$%02.2f",Float(tax*subTotal)))", path: path,alignment: .right)
        
        //Total
        subTotalRect.origin.y -= kRowHeight
        path = setupTextBox(inRect:subTotalRect)
        drawText(writeContext, text:" \(String(format: "$%02.2f",Float(total)))", path: path,alignment: .right)
        
        
        
        return 0
    }
    
    func drawInvoiceFooter(_ writeContext : CGContext, template : EEBInvoiceTemplate){
        let frame = template.footerRect
        let path = setupTextBox(inRect:frame)
        drawText(writeContext, text: " Thanks for your business!", path: path, alignment: .center)
    }
    
    
}
