//
//  InvoiceTemplate.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-25.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation
import AppKit

class EEBInvoiceTemplate {
    
    //Layout
    var toBounds : CGRect = CGRect.zero, fromBounds : CGRect = CGRect.zero, titleBounds : CGRect = CGRect.zero
    var bodyRect : CGRect = CGRect.zero
    var footerRect : CGRect = CGRect.zero
    
    //Style
    var style : [String : [String : AnyObject]] = [String : [String : AnyObject]]()
    
    
    
    init(templateName : String ){
        var json : [String : AnyObject] = [String : AnyObject]()
        if let path = Bundle.main.path(forResource: templateName, ofType: "json")
        {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)

                if jsonResult is [String : AnyObject] {
                    json = jsonResult as! [String : AnyObject]
                }
            } catch _ {
                
            }
        }
        
        //Parse template object
        if(validateJSON(json)){
            parseTemplate(json)
        } else {
            exit(0)
        }

    }
    
    func parseTemplate(_ json : [String : AnyObject]){
        
        /********** Layout Parsing ************/
        let layoutDict = json["layout"]! as? [String : AnyObject]

        //parse the header layout
        let headerLayoutJSON = layoutDict!["header"] as? [String : AnyObject]
        toBounds = parseRect((headerLayoutJSON!["to"]  as? [String : AnyObject])!)
        fromBounds = parseRect((headerLayoutJSON!["from"]  as? [String : AnyObject])!)
        titleBounds = parseRect((headerLayoutJSON!["title"] as? [String : AnyObject])!)

        //parse the body layout
        let bodyLayoutJSON : [String : AnyObject] = (layoutDict!["body"] as? [String : AnyObject])!
        bodyRect = parseRect(bodyLayoutJSON)
        
        //parse the body layout
        let footerLayoutJSON : [String : AnyObject] = (layoutDict!["footer"] as? [String : AnyObject])!
        footerRect = parseRect(footerLayoutJSON)
        
        /********** Style Parsing ************/
        let styleJSON = json["style"]! as? [String : AnyObject]
        for key in styleJSON!.keys {
            style[key] = [String : AnyObject]()
            if let sectionStyle = styleJSON![key] as? [String : AnyObject] {
                if let colorsJSON = sectionStyle["colors"] as? [String : AnyObject] {
                    style[key]!["colors"] = parseColors(colorsJSON) as AnyObject?
                }
                
                if let fontJSON = sectionStyle["font"] as? [String : AnyObject] {
                    style[key]!["font"] = parseFont(fontJSON)
                }
            }
        }

        
    }
    
    /**
     * @name    parseRect
     * @brief   Helper method to parse JSON into a CGRect
     */
    func parseRect(_ rectJSON : [String : AnyObject]) -> CGRect {
        if(validateKeys(rectJSON, keys: ["origin","size"],exhaustive: false)){
            return CGRect(x: rectJSON["origin"]!["x"]! as! CGFloat,y: rectJSON["origin"]!["y"]! as! CGFloat,width: rectJSON["size"]!["width"]! as! CGFloat,height: rectJSON["size"]!["height"]! as! CGFloat)
        } else {
            print("Invalid rect json: \(rectJSON)")
            return CGRect.zero
        }
    }
    
    
    /** 
     * @name    parseFont
     * @brief   Helper method to parse JSON into NSFont objects
     */
    func parseFont(_ fontJSON : [String : AnyObject]) -> NSFont {
        var font = NSFont.systemFont(ofSize: NSFont.systemFontSize())

        let valid = validateKeys(fontJSON, keys: ["font-name","font-size","font-style"])
        guard valid else {
            return font
        }
        
        
        if let name = fontJSON["font-name"] as? String,let style = fontJSON["font-style"] as? String, let size = fontJSON["font-size"] as? Float {
            let fontName = "\(name) \(style)"
            font = NSFont(name: fontName, size: CGFloat(size)) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize())
        }
        return font
    }
     
     
    /**
     * @name    parseColors
     * @brief   Helper method to parse JSON into CGColor objects
     */
    func parseColors(_ colorJSON : [String : AnyObject]) -> [String : CGColor] {
        let valid = validateKeys(colorJSON, keys: ["text","fill","stroke"])
        guard valid else {
            return [String : CGColor]()
        }
        var colors = [String : CGColor]()
        
        for key in colorJSON.keys {
            if let colorValue = colorJSON[key] as? String {
                switch(colorValue[colorValue.startIndex]){
                    case "#":
                        //parse hex codes
                        let hex = colorValue[colorValue.characters.index(after: colorValue.startIndex) ..< colorValue.endIndex]
                        let r = CGFloat(Int(hex[hex.startIndex ... hex.characters.index(after: hex.startIndex)],radix:  16)! / 255)
                        let g = CGFloat(Int(hex[hex.characters.index(hex.startIndex, offsetBy: 2) ... hex.characters.index(hex.startIndex, offsetBy: 3)],radix:  16)! / 255)
                        let b = CGFloat(Int(hex[hex.characters.index(hex.startIndex, offsetBy: 4) ... hex.characters.index(hex.startIndex, offsetBy: 5)],radix:  16)! / 255)
                        let color = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(),components: [r,g,b,1.0])
                        colors[key] = color
                        break
                    default:
                        print("Invalid colour specification in JSON!")
                        break
                }
                
            }
        }
        
        
        
        return colors
    }
    
    /**
     * @name    validateJSON
     * @brief   Checks that the template JSON meets at least the minimum requirements (see README)
     */
    func validateJSON(_ json : [String : AnyObject]) -> Bool{
        guard json.count > 0 else {
            print("Invalid template JSON")
            return false
        }
        
        var valid = true
        
        let layoutDict = json["layout"]! as? [String : AnyObject]
        guard layoutDict != nil else {
            return false
        }
        
        let keys = ["header","body","footer"]
        valid = validateKeys(layoutDict!,keys:keys,exhaustive: true)
        valid = valid && validateKeys(layoutDict![keys[0]] as! [String : AnyObject], keys: ["title","from","to"],exhaustive: true)
        valid = valid && validateKeys(layoutDict![keys[1]] as! [String : AnyObject], keys: ["origin","size"],exhaustive: true)
        valid = valid && validateKeys(layoutDict![keys[2]] as! [String : AnyObject], keys: ["origin","size"],exhaustive: true)

        
        //A style can be applied to any non-leaf node
        if let styleDict = json["style"]! as? [String : AnyObject]{
            //recursively search tree for key
            for key in styleDict.keys {
                valid = valid && validateKeys(styleDict[key] as! [String : AnyObject], keys:["font","colors"],exhaustive: true)
            }
        }
        return valid
    }
    
    /**
     * @name    validateKeys
     * @brief   Checks that the keys are in the dictionary. Non-exhaustive search just checks the topmost level
     *          exhaustive does a BFS for each key
     */
    func validateKeys(_ json : [String : AnyObject], keys : [String], exhaustive : Bool = false) -> Bool {
        if exhaustive {
            var present = true
            for key in keys {
                present = present && findKey(key, inDict: json)
            }
            return present
        } else {
            //check the first level
            for key in keys {
                if(json[key] == nil){
                    return false
                }
            }
            return true
        }
    }
    
    /**
     * @name    findKey
     * @brief   Recursively searches the dictionary for searchKey
     */
    func findKey(_ searchKey : String, inDict dict : [String : AnyObject]) -> Bool {
        var keyFound = false
        for key in dict.keys {
            keyFound = (dict[searchKey] != nil)
            
            if dict[key] is [String : AnyObject] {
                keyFound = keyFound || findKey(searchKey, inDict: (dict[key] as? [String : AnyObject])!)
            } else {
                return false
            }
        }
        return keyFound
    }
    
    
}
