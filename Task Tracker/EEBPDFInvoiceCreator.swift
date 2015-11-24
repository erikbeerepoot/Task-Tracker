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
        CGContextTranslateCTM(writeContext,0,Format_A4_72DPI.height)
        CGContextScaleCTM(writeContext, 1.0,-1.0);

        
        createInvoiceHeader(writeContext,forClient:user, andUser:client)
        
//        CGContextMoveToPoint(writeContext, 10, 10)
//        CGContextAddLineToPoint(writeContext, 50, 50)
//        CGContextAddLineToPoint(writeContext, 50, 100)
//        CGContextClosePath(writeContext)
//        CGContextStrokePath(writeContext)
        
        CGContextEndPage(writeContext)
        
        
        CGPDFContextClose(writeContext)

        return true
    }

    /**
     * @name    createInvoiceHeader
     * @brief   Creates the header for the invoice (company info, title, etc)
     */
    func createInvoiceHeader(writeContext : CGContextRef, forClient client : Client, andUser user : Client){



        CGContextSetTextMatrix(writeContext, CGAffineTransformIdentity);

        func setupTextBox(x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat) -> CGMutablePathRef{
            let origin = CGPoint(x:self.margin_H,y:self.margin_V)
            let path = CGPathCreateMutable()
            let bounds = CGRectMake(origin.x + x, origin.y + y, width, height);
            CGPathAddRect(path,nil,bounds)
            return path
        }
        
        func drawText( text : String, path : CGMutablePathRef){
            //Create attributed version of the string & draw
            let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
            CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0),text);
            let frameSetter = CTFramesetterCreateWithAttributedString(attrString);
            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil);
            
            CTFrameDraw(frame, writeContext);

        }
        
        /***** Draw our company info *****/
        let _ : () = {
            let path = setupTextBox(0, y:0, width:200, height:100)
            
            //Create *our* company info
            var textString =  user.company! + "\r"
            textString += user.name! + "\r"
//            textString += user.address! + "\r"

            drawText(textString, path: path)
        }()
        
        
        /***** Draw document title *****/
        let _ = {
            let path = setupTextBox(200, y:0, width: 200, height: 100)
            let text = "Invoice"
            drawText(text, path: path)
        }()
        

    }
    
    func createJoblist(){
        
    }
    
    
}