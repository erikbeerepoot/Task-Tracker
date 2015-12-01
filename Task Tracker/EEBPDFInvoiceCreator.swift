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
    
    //Metadata for PDF
    var metadata : Dictionary<String,String> = Dictionary<String,String>()
    
    
    let user : Client, client : Client;
    
    init(userinfo : Client, client : Client){
       self.user = userinfo
       self.client = client
        
        
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

        
        //flip coordinate system
        CGContextBeginPage(writeContext, &mediaBox)
//        CGContextTranslateCTM(writeContext,0,Format_A4_72DPI.height)
//        CGContextScaleCTM(writeContext, 1.0,-1.0);
        
        //Flip coordinate system for text
//        let textTransform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
        let textTransform = CGAffineTransformIdentity
        CGContextSetTextMatrix(writeContext,textTransform)
        
        createInvoiceHeader(writeContext,template:template,forClient:user, andUser:client)
        

        
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
    
    /**
     * @name    createInvoiceHeader
     * @brief   Creates the header for the invoice (company info, title, etc)
     */
    func createInvoiceHeader(writeContext : CGContextRef, template : InvoiceTemplate, forClient client : Client, andUser user : Client){


        /***** Draw our company info *****/
        let _ : () = {
            let path = setupTextBox(0, y:Format_A4_72DPI.height - 250, width:200, height:100)
            
            //Create *our* company info
            var textString = user.name! + "\r"
            textString +=  user.company! + "\r"

            drawText(writeContext,text:textString, path: path,font:nil)
        }()
        
        
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
            rectFrame.size.height = 20

            CGContextStrokeRect(writeContext, rectFrame)
            CGContextFillRect(writeContext, rectFrame)
            
            let path = setupTextBox(inRect:template.toBounds)
            let text = "Company 1 \n Address \n Country"
            let font = NSFont(name: "Helvetica Neue", size: 22.0)
            drawText(writeContext,text:text, path: path,font:font)
        }()
        
        let _ = {
            var rectFrame = template.fromBounds
            CGContextStrokeRect(writeContext, rectFrame)
            rectFrame.origin.y += rectFrame.size.height
            rectFrame.size.height = 20
            CGContextStrokeRect(writeContext, rectFrame)
            CGContextFillRect(writeContext, rectFrame)
            
            let path = setupTextBox(inRect:template.fromBounds)
            let text = "Company 1"
            let font = NSFont(name: "Helvetica Neue", size: 22.0)
            drawText(writeContext,text:text, path: path,font:font)
        }()
        

    }
        
    func createJoblist(){
        
    }
    
    
}