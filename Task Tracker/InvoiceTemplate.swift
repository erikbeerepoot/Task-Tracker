//
//  InvoiceTemplate.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-25.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation

class InvoiceTemplate {
    
    //Layout
    var toBounds : CGRect = CGRectZero, fromBounds : CGRect = CGRectZero, titleBounds : CGRect = CGRectZero
    var bodyRect : CGRect = CGRectZero
    var footerRect : CGRect = CGRectZero
    
    //Style
    var style : [String : AnyObject] = [String:AnyObject]()
    
    
    
    init(templateName : String ){
        var json : [String : AnyObject] = [String : AnyObject]()
        if let path = NSBundle.mainBundle().pathForResource(templateName, ofType: "json")
        {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)

                if jsonResult is [String : AnyObject] {
                    json = jsonResult as! [String : AnyObject]
                }

            } catch _ {
                
            }
        }
        
        //Parse template object
        if(validateJSON(json)){
            parseTemplate(json)
        }

    }
    
    func parseTemplate(json : [String : AnyObject]){
        
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
            
        }
        //STUB
        //STUBBY
        //STUB
    }
    
    /**
     * @name    parseRect
     * @brief   Helper method to parse JSON into a CGRect
     */
    func parseRect(rectJSON : [String : AnyObject]) -> CGRect {
        if(validateKeys(rectJSON, keys: ["origin","size"],exhaustive: false)){
            return CGRectMake(rectJSON["origin"]!["x"]! as! CGFloat,rectJSON["origin"]!["y"]! as! CGFloat,rectJSON["size"]!["width"]! as! CGFloat,rectJSON["size"]!["height"]! as! CGFloat)
        } else {
            print("Invalid rect json: \(rectJSON)")
            return CGRectZero
        }
    }
    
    /**
     * @name    validateJSON
     * @brief   Checks that the template JSON meets at least the minimum requirements (see README)
     */
    func validateJSON(json : [String : AnyObject]) -> Bool{
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
                print(findKey(key, inDict: layoutDict!))
            }
        }
        return valid
    }
    
    /**
     * @name    validateKeys
     * @brief   Checks that the keys are in the dictionary. Non-exhaustive search just checks the topmost level
     *          exhaustive does a BFS for each key
     */
    func validateKeys(json : [String : AnyObject], keys : [String], exhaustive : Bool) -> Bool {
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
    func findKey(searchKey : String, inDict dict : [String : AnyObject]) -> Bool {
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