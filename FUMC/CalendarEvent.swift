//
//  CalendarEvent.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/10/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CalendarEvent: NSObject {
    
    var id: String
    var name: String
    var descript: String
    var from: NSDate
    var to: NSDate
    var location: String
    var calendar: Calendar
    var allDay: Bool {
        if (self.from.hour() == 0 && self.from.minute() == 0 && self.to.hour() == 23 && self.to.minute() == 59) {
            return true
        }
        return false
    }
    
    init(jsonDictionary: NSDictionary, calendar: Calendar, dateFormatter: NSDateFormatter) {

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.id = jsonDictionary["id"] as! String
        self.name = jsonDictionary["name"] as! String
        self.from = dateFormatter.dateFromString(jsonDictionary["from"] as! String)!
        self.to = dateFormatter.dateFromString(jsonDictionary["to"] as! String)!
        self.descript = ""
        self.location = ""
        self.calendar = calendar
        
        if let description: String = jsonDictionary["description"] as? String {
            self.descript = description
        }
        
        if let location: NSDictionary = jsonDictionary["location"] as? NSDictionary {
            self.location = location["name"] as! String
        }
    }
   
}
