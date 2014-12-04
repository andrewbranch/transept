//
//  Notification.swift
//  FUMC
//
//  Created by Andrew Branch on 11/26/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Notification: NSObject {
    
    var id: Int
    var sendDate: NSDate
    var expirationDate: NSDate?
    var message: String
    var url: String
    
    init(userInfo: [NSObject : AnyObject]) {
        let data = userInfo["aps"] as NSDictionary
        let custom = userInfo["info"] as NSDictionary
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        self.id = 0
        // This will be nil if the notification sent but failed to save to Postgres
        if let id = custom["id"] as? String {
            self.id = id.toInt()!
        }
        self.sendDate = dateFormatter.dateFromString(custom["sendDate"] as String)!
        self.expirationDate = nil // don't care about this
        self.message = data["alert"] as String
        self.url = custom["url"] as String
    }
    
    override init() {
        self.id = 0
        self.sendDate = NSDate()
        self.expirationDate = NSDate()
        self.message = ""
        self.url = ""
    }

}
