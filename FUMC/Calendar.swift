//
//  Calendar.swift
//  FUMC
//
//  Created by Andrew Branch on 12/5/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Calendar: NSObject {
    
    var id: String
    var name: String
    var colorString: String?
    var color = UIColor(white: 0.9, alpha: 0.9)
    var events = [CalendarEvent]()
    
    override init() {
        self.id = ""
        self.name = ""
    }
    
    init(jsonDictionary: NSDictionary) {
        self.id = jsonDictionary["id"] as String
        self.name = jsonDictionary["name"] as String
        if let colorString = jsonDictionary["colorString"] as? String {
             self.color = UIColor.colorWithHexString(colorString)
        }
    }
   
}
