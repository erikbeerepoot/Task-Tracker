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
    let kRowHeight = CGFloat(20)
    
    let columnWidths : [CGFloat] = [200,81.3,81.3,81.3]
    let columnNames : [String] = ["Job","Quantity","Price","Cost"]
    
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
        
        let template = InvoiceTemplate(templateName: "Basic")
        
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
    func setupTextBox(x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat) -> CGMutablePathRef{
        let origin = CGPoint(x:self.margin_H,y:self.margin_V)
        let path = CGPathCreateMutable()
        let bounds = CGRectMake(origin.x + x, origin.y + y, width, height);
        CGPathAddRect(path,nil,bounds)
        return path
    }
    
    func setupTextBox(inRect rect : CGRect) -> CGMutablePathRef{
        let path = CGPathCreateMutable()
        let bounds = CGRectMake(rect.origin.x,rect.origin.y, rect.size.width, rect.size.height);
        CGPathAddRect(path,nil,bounds)
        return path
    }
    
    
    
    func drawText(context : CGContextRef,text : String, path : CGMutablePathRef, font : NSFont?){
        //Create attributed version of the string & draw
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0),text);
        
        if(font != nil){
            CFAttributedStringSetAttribute(attrString,CFRangeMake(0, text.characters.count),NSFontAttributeName,font!)
        }
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString);
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
        CTFrameDraw(frame, context);
    }
    
    
    func drawText(context : CGContextRef,text : String, path : CGMutablePathRef, attributes : [String : AnyObject]?){
        //Create attributed version of the string & draw
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0),text);
        
        if(attributes != nil){
            CFAttributedStringSetAttributes(attrString, CFRangeMake(0, text.characters.count), attributes, true)
        }
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attrString);
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
        CTFrameDraw(frame, context);
    }
    
    /**
     * @name    createInvoiceHeader
     * @brief   Creates the header for the invoice (company info, title, etc)
     */
    func drawInvoiceHeader(writeContext : CGContextRef, template : InvoiceTemplate, forClient client : Client, andUser user : Client){


//        /***** Draw our company info *****/
//        let _ : () = {
//            let path = setupTextBox(0, y:Format_A4_72DPI.height - 250, width:200, height:100)
//            
//            //Create *our* company info
//            var textString = user.name! + "\r"
//            textString +=  user.company! + "\r"
//
//            drawText(writeContext,text:textString, path: path,font:nil)
//        }()
        
        
        /***** Draw document title *****/
        let _ = {
            let path = setupTextBox(inRect:template.titleBounds)
            let text = "Invoice"
            let font = NSFont(name: "Helvetica Neue Bold", size: 25.0)
            
            //CGContextStrokeRect(writeContext, template.titleBounds)
            drawText(writeContext,text:text, path: path,font:font)
        }()
        
        let _ = {
            var rectFrame = template.toBounds
            CGContextStrokeRect(writeContext, rectFrame)
            rectFrame.origin.y += rectFrame.size.height
            rectFrame.size.height = kHeaderHeight

            //fill header box
            CGContextStrokeRect(writeContext, rectFrame)
            CGContextFillRect(writeContext, rectFrame)
            
            //Set header text
            let font = NSFont(name: "Helvetica Neue", size: 14.0)
            var attributes = [String : AnyObject]()
            attributes[NSFontAttributeName] = font!
            attributes[NSForegroundColorAttributeName] = NSColor.whiteColor()
            let headerPath = setupTextBox(inRect: rectFrame)
            drawText(writeContext, text: "to:", path: headerPath, attributes: attributes)
            
            let path = setupTextBox(inRect:template.toBounds)
            let text = client.name! + "\n" + client.company!
            drawText(writeContext,text:text, path: path,font:font)
        }()
        
        let _ = {
            
            var rectFrame = template.fromBounds
            CGContextSetStrokeColor(writeContext, CGColorGetComponents(NSColor.blackColor().CGColor))
            CGContextStrokeRect(writeContext, rectFrame)
            rectFrame.origin.y += rectFrame.size.height
            rectFrame.size.height = kHeaderHeight
            CGContextStrokeRect(writeContext, rectFrame)
            CGContextFillRect(writeContext, rectFrame)
            
            //Set header text
            let font = NSFont(name: "Helvetica Neue", size: 14.0)
            var attributes = [String : AnyObject]()
            attributes[NSFontAttributeName] = font!
            attributes[NSForegroundColorAttributeName] = NSColor.whiteColor()
            let headerPath = setupTextBox(inRect: rectFrame)
            drawText(writeContext, text: "from:", path: headerPath, attributes: attributes)
            
            let path = setupTextBox(inRect:template.fromBounds)
            let text = user.name! + "\n" + user.company!
            drawText(writeContext,text:text, path: path,font:font)
        }()
        

    }
    
    func drawInvoiceBody(writeContext : CGContextRef, template : InvoiceTemplate, withJobs jobs : [Job]) -> Int{
        //draw enclosing rectangle for body
        var bodyFrame = template.bodyRect
        CGContextSetStrokeColor(writeContext, CGColorGetComponents(NSColor.blackColor().CGColor))
        CGContextStrokeRect(writeContext, bodyFrame)
    
        //draw the header rectangle
        bodyFrame.origin.y += bodyFrame.size.height - kHeaderHeight
        bodyFrame.size.height = kHeaderHeight
        CGContextFillRect(writeContext, bodyFrame)
    
        //add text to the header
        var columnFrame = bodyFrame
        for var idx = 0;idx<columnWidths.count;idx++ {
            columnFrame.size.width = columnWidths[idx]
            
            let font = NSFont(name: "Helvetica Neue", size: 14.0)
            var attributes = [String : AnyObject]()
            attributes[NSFontAttributeName] = font!
            attributes[NSForegroundColorAttributeName] = NSColor.whiteColor()
            
            let path = setupTextBox(inRect: columnFrame)
            drawText(writeContext, text: columnNames[idx]+":", path: path, attributes: attributes)
            
            columnFrame.origin.x += columnWidths[idx]
        }
        
        
        //The max number of jobs that can fit on this page
        let pageJobCount = Int(((template.bodyRect.size.height - kHeaderHeight) / kRowHeight))

        //If we have more jobs than we can fit, fill this page to start
        var numJobsToDraw = jobs.count
        if(jobs.count > pageJobCount){
            numJobsToDraw = pageJobCount
        }

        var frame = bodyFrame
        for(var jobIdx=0;jobIdx<numJobsToDraw;jobIdx++){
            frame = CGRectMake(frame.origin.x,frame.origin.y - kRowHeight,frame.size.width,kRowHeight)
            
            //draw text
            let job = jobs[jobIdx]
            var path = setupTextBox(inRect:frame)
            drawText(writeContext, text: " \(job.name)", path: path, font: nil)
            
            frame.origin.x += columnWidths[0]
            path = setupTextBox(inRect:frame)
            drawText(writeContext, text: " \(job.totalTimeString())", path: path, font: nil)
            
            frame.origin.x += columnWidths[1]
            path = setupTextBox(inRect:frame)
            var rate = client.hourlyRate
            if(job.rate != nil && job.rate!.doubleValue > 0.0){
                rate = job.rate!
            }
            
            let rateString = String(format: "$%02.2f",rate)
            drawText(writeContext, text: " \(rateString)", path: path, font: nil)

            frame.origin.x += columnWidths[2]
            path = setupTextBox(inRect:frame)
            drawText(writeContext, text: " \(job.cost())", path: path, font: nil)
            
            
            //draw dividing line
            frame.origin.x = bodyFrame.origin.x
            CGContextSetStrokeColor(writeContext, CGColorGetComponents(NSColor.blackColor().CGColor))
            CGContextSetLineWidth(writeContext, 0.25)
            CGContextStrokeLineSegments(writeContext, [CGPointMake(frame.origin.x,frame.origin.y),CGPointMake(frame.origin.x+frame.size.width,frame.origin.y)], 2)
        }
        
        CGContextSetLineWidth(writeContext, 1)
        CGContextSetStrokeColor(writeContext, CGColorGetComponents(NSColor.blackColor().CGColor))
        
        //Subtotal
        var subTotalRect = CGRectMake(template.bodyRect.origin.x + (template.bodyRect.size.width / 2), template.bodyRect.origin.y - kRowHeight, (template.bodyRect.size.width / 2), kRowHeight)
        CGContextStrokeRect(writeContext, subTotalRect)

        //Tax
        subTotalRect.origin.y -= kRowHeight
        CGContextStrokeRect(writeContext, subTotalRect)

        //Total
        subTotalRect.origin.y -= kRowHeight
        subTotalRect.origin.y += 2
        CGContextStrokeRect(writeContext, subTotalRect)

        
        
        return 0
    }
    
    func drawInvoiceFooter(writeContext : CGContextRef, template : InvoiceTemplate){
        let frame = template.footerRect
        
        
                CGContextStrokeRect(writeContext, frame)
        let path = setupTextBox(inRect:frame)
        drawText(writeContext, text: " Thanks for your business!", path: path, font: nil)
        
    }
    
    
    func createJoblist(){
        
    }
    
    
}