//
//  InvoiceTemplate.swift
//  Task Tracker
//
//  Created by Erik Beerepoot on 2015-11-25.
//  Copyright © 2015 Barefoot Systems. All rights reserved.
//

import Foundation

class InvoiceTemplate {
    
    var header : CGRect = CGRectZero,body : CGRect = CGRectZero, footer : CGRect = CGRectZero
    
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
        validateJSON(json)

    }
    
    func parseTemplate(json : [String : AnyObject]){
        print(json)
    }
    
    func validateJSON(json : [String : AnyObject]) -> Bool{
        var valid = true
        
        let layoutDict = json["layout"]! as? Dictionary<String,AnyObject>
        guard layoutDict != nil else {
            return false
        }
        
        let keys = ["header","body","footer"]
        valid = validateKeys(layoutDict!,keys:keys)
        valid = valid && validateKeys(layoutDict![keys[0]] as! [String : AnyObject], keys: ["title","from","to"])
        valid = valid && validateKeys(layoutDict![keys[1]] as! [String : AnyObject], keys: ["origin","size"])
        valid = valid && validateKeys(layoutDict![keys[2]] as! [String : AnyObject], keys: ["origin","size"])

        
        //A style can be applied to any non-leaf node
        if let styleDict = json["style"]! as? Dictionary<String,AnyObject>{
            //recursively search tree for key
            for key in styleDict.keys {
                print(findKey(key, inDict: layoutDict!))
            }
        }
        
        return valid
    }
    
    func validateKeys(json : [String : AnyObject], keys : [String]) -> Bool {
        for key in keys {
            if(json[key] == nil){
                return false
            }
        }
        return true
    }
    
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