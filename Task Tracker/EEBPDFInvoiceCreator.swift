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
    
    func setMetadata(userinfo : Client, client : Client){
        metadata[String(kCGPDFContextTitle)] = NSLocalizedString("Invoice",comment: "Invoice")
        metadata[String(kCGPDFContextCreator)] = userinfo.name
        
    }
        
    func createPDF(atPath path : String, withFilename filename : String) -> Bool {
        
        let template = EEBInvoiceTemplate(templateName: "Basic")
        
        //Attempt to create PDF context
        let path = CFStringCreateWithCString(nil, path+filename, CFStringBuiltInEncodings.UTF8.rawValue);
        let url = CFURLCreateWithFileSystemPath(nil,path,CFURLPathStyle.CFURLPOSIXPathStyle,false)
        guard let writeContext = CGPDFContextCreateWithURL(url, nil, metadata) else {
            print("Failed to create PDF context at URL \(url)")
            return false
        }

        var mediaBox: CGRect = CGRectMake(0, 0, Format_A4_72DPI.width, Format_A4_72DPI.height)

        CGContextBeginPage(writeContext, &mediaBox)

        let textTransform = CGAffineTransformIdentity
        CGContextSetTextMatrix(writeContext,textTransform)
        
        drawInvoiceHeader(writeContext,template:template,forClient:user, andUser:client)
        drawInvoiceBody(writeContext, template:template,withJobs:jobs)
        drawInvoiceFooter(writeContext,template: template)
        
        CGContextEndPage(writeContext)
        CGPDFContextClose(writeContext)
        return true
    }

    
    //MARK: Helpers
    
    
    /** 
     * @name    setupTextBox
     * @brief   Creates a new path (a text box) from the given rectangle
     */
    func setupTextBox(x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat) -> CGMutablePathRef{
        let origin = CGPoint(x:self.margin_H,y:self.margin_V)
        let path = CGPathCreateMutable()
        let bounds = CGRectMake(origin.x + x + 2*kTextInset, origin.y + y + kTextInset, width - 3*kTextInset, height);
        CGPathAddRect(path,nil,bounds)
        return path
    }
    
    func setupTextBox(inRect rect : CGRect) -> CGMutablePathRef{
        let path = CGPathCreateMutable()
        let bounds = CGRectMake(rect.origin.x + 2*kTextInset,rect.origin.y - kTextInset, rect.size.width -  3*kTextInset, rect.size.height );
        CGPathAddRect(path,nil,bounds)
        return path
    }
    
    

    /**
     * @name    drawText
     * @brief   Draws the given string on the given path
     * @notes   Changes colour settings (stroke,fill) of context
     */
    func drawText(context : CGContextRef,text : String, path : CGMutablePathRef, font : NSFont = NSFont.systemFontOfSize(NSFont.systemFontSize()),alignment : CTTextAlignment = .Left){
       
        var attributes = [String : AnyObject]()
        attributes[NSFontAttributeName] = font
        
        //Set alignment
        var alignmentVar : CTTextAlignment = alignment
        let alignmentSetting = [CTParagraphStyleSetting(spec: .Alignment , valueSize: sizeofValue(alignmentVar), value: &alignmentVar)]
        let paragraphStyle = CTParagraphStyleCreate(alignmentSetting,1)
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        
        
        drawText(context, text: text, path: path, attributes: attributes)
    }
    
    
    func drawText(context : CGContextRef,text : String, path : CGMutablePathRef, attributes : [String : AnyObject]){
        CGContextSaveGState(context);
        
        //Create attributed version of the string & draw
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0),text);
        
        attributes.forEach({CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), $0.0,$0.1)})
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString);
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
        CTFrameDraw(frame, context);
        
        CGContextRestoreGState(context);
    }
    
    /**
     * @name    drawTable
     * @brief   Draws a table inside the given rectangle
     */
    func drawTable(context : CGContextRef,
               inRect rect : CGRect,
                   numRows : Int,
                   numCols : Int,
                rowHeaders : [String] = [],
                colHeaders : [String] = [],
           drawRowDividers : Bool = true,
           drawColDividers : Bool = true,
                 textColor : NSColor = NSColor.whiteColor(),
               strokeColor : NSColor = NSColor.blackColor(),
                 fillColor : NSColor = NSColor.blackColor()){
                    
        
                    
        guard (rowHeaders.count == 0 || rowHeaders.count == numRows) &&
            (colHeaders.count == 0 || colHeaders.count == numCols) else {
                return
        }
                    
        //Before we change any context properties, we save the state
        CGContextSaveGState(context);
        CGContextSetStrokeColor(context, CGColorGetComponents(strokeColor.CGColor))
        CGContextSetFillColor(context, CGColorGetComponents(fillColor.CGColor))
                    
        //Create bounding box
        CGContextStrokeRect(context, rect)
        
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
        var colHeaderRect = CGRectMake(rect.origin.x + horizontalOffset, rect.origin.y + rect.size.height - kHeaderHeight, headerWidth, kHeaderHeight)
        for colHeader in colHeaders {
            //fill the header with the appropriate colour
            CGContextFillRect(context, colHeaderRect)
            
            //Create header text
            let textPath = setupTextBox(inRect: colHeaderRect)
            drawText(context, text: colHeader, path: textPath, attributes: attributes)
            
            //next header starts where this one ends
            colHeaderRect.origin.x += headerWidth
        }
             
                    
        //If we were given row headers, draw them
        var rowHeaderRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - kHeaderHeight, kHeaderWidth, kRowHeight)
        for rowHeader in rowHeaders {
            //fill the header with the appropriate colour
            CGContextFillRect(context, rowHeaderRect)
            
            //Create header text
            let textPath = setupTextBox(inRect: rowHeaderRect)
            drawText(context, text: rowHeader, path: textPath, attributes: attributes)
            
            //next header starts where this one ends
            rowHeaderRect.origin.y -= kRowHeight
        }
                    
        //Draw the table inside dividers
        let origin : CGPoint = CGPointMake(rect.origin.x + horizontalOffset, colHeaderRect.origin.y - (colHeaders.count > 0 ? kHeaderHeight : 0))
        let xs = origin.x.stride(to: (origin.x + CGFloat(numCols)*headerWidth), by: headerWidth)
        let ys = origin.y.stride(to: rect.origin.y, by: -kRowHeight)
                print(ys)
        CGContextSetLineWidth(context, 0.25)

        if(drawColDividers){
            xs.forEach(){CGContextStrokeRect(context, CGRectMake($0,colHeaderRect.origin.y,headerWidth,kHeaderHeight-rect.size.height))}
        }
                    
        if(drawRowDividers){
            ys.forEach(){CGContextStrokeRect(context, CGRectMake(origin.x,$0,rect.size.width-horizontalOffset,kRowHeight))}
        }
                    
        CGContextRestoreGState(context);
    }
    
    /**
     * @name    createInvoiceHeader
     * @brief   Creates the header for the invoice (company info, title, etc)
     */
    func drawInvoiceHeader(writeContext : CGContextRef, template : EEBInvoiceTemplate, forClient client : Client, andUser user : Client){


        /***** Draw document title *****/
        var frame = template.titleBounds
        var path = setupTextBox(inRect:frame)
        var text = "Invoice"
        var font = (template.style["title"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue Bold", size: 25.0)
        drawText(writeContext,text:text, path: path,font:font!)

        
        /************* Dates ***************/
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.locale = NSLocale.currentLocale()

        
        //Invoice date
        font = (template.style["title-dates"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue", size: 14.0)
        
        frame.origin.y -= 30
        path = setupTextBox(inRect:frame)
        text = "Invoice date: \t \(formatter.stringFromDate(NSDate()))"
        drawText(writeContext,text:text, path: path,font:font!)

        //Due date
        frame.origin.y -= 20
        path = setupTextBox(inRect:frame)
        text = "Due date: \t \t \(formatter.stringFromDate(NSDate().dateByAddingTimeInterval(1210000)))"
        drawText(writeContext,text:text, path: path,font:font!)            
        
        /****** Draw to & from box ******/
        font = (template.style["to"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue", size: 14.0)
        drawTable(writeContext, inRect:template.toBounds, numRows: 5, numCols: 1,colHeaders:["To:"],drawRowDividers:false)
        path = setupTextBox(inRect:CGRectMake(template.toBounds.origin.x,template.toBounds.origin.y - kRowHeight,template.toBounds.size.width,template.toBounds.size.height))
        text = client.name! + "\n" + client.company!
        drawText(writeContext,text:text, path: path,font:font!)

        font = (template.style["to"]?["font"] as? NSFont) ?? NSFont(name: "Helvetica Neue", size: 14.0)
        drawTable(writeContext, inRect:template.fromBounds, numRows: 5, numCols: 1,colHeaders:["From:"],drawRowDividers:false)
        path = setupTextBox(inRect:CGRectMake(template.fromBounds.origin.x,template.fromBounds.origin.y - kRowHeight,template.fromBounds.size.width,template.fromBounds.size.height))
        text = user.name! + "\n" + user.company!
        drawText(writeContext,text:text, path: path,font:font!)
    }
    


    
    func drawInvoiceBody(writeContext : CGContextRef, template : EEBInvoiceTemplate, withJobs jobs : [Job]) -> Int{
            let columnNames : [String] = ["Job:","Quantity:","Rate:","Cost:"]
        
        //The max number of jobs that can fit on this page
        let pageJobCount = Int(((template.bodyRect.size.height - kHeaderHeight) / kRowHeight))

        //If we have more jobs than we can fit, fill this page to start
        var numJobsToDraw = jobs.count
        if(jobs.count > pageJobCount){
            numJobsToDraw = pageJobCount
        }
        
        drawTable(writeContext, inRect:template.bodyRect,numRows:numJobsToDraw,numCols:columnNames.count,colHeaders:columnNames)

        let frame = CGRectMake(template.bodyRect.origin.x, template.bodyRect.origin.y + template.bodyRect.size.height - kRowHeight, template.bodyRect.size.width, template.bodyRect.size.height)
        let columnWidth = template.bodyRect.size.width / CGFloat(columnNames.count)
        for(var jobIdx=0;jobIdx<numJobsToDraw;jobIdx++){
            var currentFrame = CGRectMake(frame.origin.x,frame.origin.y - kRowHeight - CGFloat(jobIdx)*kRowHeight,columnWidth,kRowHeight)
            
            //draw text
            let job = jobs[jobIdx]
            
            var path = setupTextBox(inRect:currentFrame)
            drawText(writeContext, text: " \(job.name)", path: path)
            
            currentFrame.origin.x += columnWidth
            path = setupTextBox(inRect:currentFrame)
            drawText(writeContext, text: " \(job.totalTimeString())", path: path,alignment: .Right)
            
            currentFrame.origin.x += columnWidth
            path = setupTextBox(inRect:currentFrame)
            var rate = client.hourlyRate
            if(job.rate != nil && job.rate!.doubleValue > 0.0){
                rate = job.rate!
            }
            
            drawText(writeContext, text: " \(String(format: "$%02.2f",Float(rate)))", path: path,alignment: .Right)

            currentFrame.origin.x += columnWidth
            path = setupTextBox(inRect:currentFrame)
            drawText(writeContext, text: " \(job.cost())", path: path,alignment: .Right)
        }
    
        
        
        //Totals headers
        var subTotalRect = CGRectMake(template.bodyRect.origin.x + (template.bodyRect.size.width / 2), template.bodyRect.origin.y - 3*kRowHeight , (template.bodyRect.size.width / 2), 3*kRowHeight)
        drawTable(writeContext,inRect: subTotalRect, numRows:3,numCols:1,rowHeaders: ["Subtotal:","Tax:","Total:"],fillColor:NSColor.darkGrayColor())
        
        //Compute totals and display
        let tax = Double(0.15)
        let subTotal = jobs.reduce(0, combine: { $0 + $1.computeCost() })
        let total = subTotal + subTotal*tax

        subTotalRect.origin.x += kHeaderWidth
        subTotalRect.origin.y += 2*kRowHeight
        subTotalRect.size.height = kRowHeight
        subTotalRect.size.width -= kHeaderWidth
        
        //Subtotal
        var path = setupTextBox(inRect:subTotalRect)
        drawText(writeContext, text:" \(String(format: "$%02.2f",Float(subTotal)))", path: path,alignment: .Right)
        
        //Tax
        subTotalRect.origin.y -= kRowHeight
        path = setupTextBox(inRect:subTotalRect)
        drawText(writeContext, text:" \(String(format: "$%02.2f",Float(tax*subTotal)))", path: path,alignment: .Right)
        
        //Total
        subTotalRect.origin.y -= kRowHeight
        path = setupTextBox(inRect:subTotalRect)
        drawText(writeContext, text:" \(String(format: "$%02.2f",Float(total)))", path: path,alignment: .Right)
        
        
        
        return 0
    }
    
    func drawInvoiceFooter(writeContext : CGContextRef, template : EEBInvoiceTemplate){
        let frame = template.footerRect
        let path = setupTextBox(inRect:frame)
        drawText(writeContext, text: " Thanks for your business!", path: path, alignment: .Center)
    }
    
    
}