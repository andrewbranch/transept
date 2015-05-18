//
//  Calendar.swift
//  FUMC
//
//  Created by Andrew Branch on 12/5/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Calendar: NSObject {
    
    var id: String = ""
    var name: String = ""
    var colorString: String?
    var defaultImageKey: String?
    
    var color = UIColor(white: 0.9, alpha: 0.9)
    var events = [CalendarEvent]()
    var defaultImage = UIImage(named: "default-event")
    
    init(jsonDictionary: NSDictionary) {
        super.init()
        self.id = jsonDictionary["id"] as! String
        self.name = jsonDictionary["name"] as! String
        if let colorString = jsonDictionary["color"] as? String {
             self.color = UIColor.colorWithHexString(colorString)
        }
        if let key = jsonDictionary["image"] as? String {
            self.defaultImageKey = key
            API.shared().getFile(key) { data, error in
                if (error != nil) { return }
                if let image = UIImage(data: data) {
                    self.defaultImage = image
                }
            }
        }
    }
   
}
