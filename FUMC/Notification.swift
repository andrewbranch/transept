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
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let sendDateString = String(Array(custom["sendDate"] as String)[0...18]) + ".000Z"

        self.id = (custom["id"] as String).toInt()!
        self.sendDate = dateFormatter.dateFromString(sendDateString)!
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
