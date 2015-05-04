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
        
        self.id = jsonDictionary["id"] as! String
        self.service = jsonDictionary["service"] as! String
        self.date = dateFormatter.dateFromString(jsonDictionary["date"] as! String)!
        self.file = jsonDictionary["file"] as! String
        self.visible = jsonDictionary["visible"] as! Bool
    }
}
