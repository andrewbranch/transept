//
//  Notification.swift
//  FUMC
//
//  Created by Andrew Branch on 11/26/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Notification: NSObject {
    
    var id: String
    var sendDate: NSDate
    var expirationDate: NSDate?
    var message: String
    var url: String
    
    init(userInfo: [NSObject : AnyObject]) {
        let data = userInfo["aps"] as! NSDictionary
        let custom = userInfo["info"] as! NSDictionary
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        self.id = ""
        // This will be nil if the notification sent but failed to save to store
        if let id = custom["id"] as? String {
            self.id = id
        }
        self.sendDate = dateFormatter.dateFromString(custom["sendDate"] as! String)!
        self.expirationDate = nil // don't care about this
        self.message = data["alert"] as! String
        
        self.url = ""
        if let url = custom["url"] as? String {
            self.url = url
        }
    }
    
    init(jsonDictionary: NSDictionary, dateFormatter: NSDateFormatter) {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.id = jsonDictionary["id"] as! String
        self.sendDate = dateFormatter.dateFromString(jsonDictionary["sendDate"] as! String)!
        self.expirationDate = dateFormatter.dateFromString(jsonDictionary["expirationDate"] as! String)!
        self.message = jsonDictionary["message"] as! String
        
        self.url = ""
        if let url = jsonDictionary["url"] as? String {
            self.url = url
        }
    }

}
