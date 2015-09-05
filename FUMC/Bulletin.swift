//
//  Bulletin.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/29/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Bulletin : NSObject {
    
    var id: String
    var service: String
    var date: NSDate
    var file: String
    var visible: Bool
    
    init(jsonDictionary: NSDictionary, dateFormatter: NSDateFormatter) {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let attrs = jsonDictionary["attributes"] as! NSDictionary
        self.id = jsonDictionary["id"] as! String
        
        self.service = attrs["service"] as! String
        self.date = dateFormatter.dateFromString(attrs["date"] as! String)!
        self.file = attrs["file"] as! String
        self.visible = attrs["visible"] as! Bool
    }
}
