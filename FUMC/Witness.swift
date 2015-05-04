//
//  Witness.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/30/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Witness: NSObject {
    
    var id: String
    var from: NSDate
    var to: NSDate
    var file: String
    var volume: Int
    var issue: Int
    var visible: Bool
    
    init(jsonDictionary: NSDictionary, dateFormatter: NSDateFormatter) {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.id = jsonDictionary["id"] as! String
        self.from = dateFormatter.dateFromString(jsonDictionary["from"] as! String)!
        self.to = dateFormatter.dateFromString(jsonDictionary["to"] as! String)!
        self.volume = jsonDictionary["volume"] as! Int
        self.issue = jsonDictionary["issue"] as! Int
        self.file = jsonDictionary["file"] as! String
        self.visible = jsonDictionary["visible"] as! Bool
    }
}
