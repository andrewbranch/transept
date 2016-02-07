//
//  Bulletin.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/29/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

public class Bulletin : NSObject {
    
    var id: String
    var service: String
    var liturgicalDay: String
    var date: NSDate
    var file: String!
    var visible: Bool
    
    public init(jsonDictionary: NSDictionary, dateFormatter: NSDateFormatter) throws {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let attrs = jsonDictionary["attributes"] as! NSDictionary
        self.id = jsonDictionary["id"] as! String
        
        self.service = attrs["service"] as! String
        self.liturgicalDay = attrs["liturgical-day"] as! String
        self.date = dateFormatter.dateFromString(attrs["date"] as! String)!
        self.visible = attrs["visible"] as! Bool
        
        super.init()
        
        guard let file = attrs["file"] as? String else {
            throw NSError(domain: "com.fumcpensacola", code: 1, userInfo: nil)
        }
        
        self.file = file
    }
}
