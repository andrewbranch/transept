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
    lazy var color: UIColor = {
        if (self.name == "50 Forward") { return UIColor.colorWithHexString("#810000") }
        if (self.name == "Children") { return UIColor.colorWithHexString("#1cc2f2") }
        if (self.name == "Christian Education") { return UIColor.colorWithHexString("#553c17") }
        if (self.name == "Church-wide Events") { return UIColor.colorWithHexString("#580808") }
        if (self.name == "Missions and Outreach") { return UIColor.colorWithHexString("#de6e1c") }
        if (self.name == "Music and Worship Arts") { return UIColor.colorWithHexString("#3b3b3b") }
        if (self.name == "Tweens") { return UIColor.colorWithHexString("#fff200") }
        if (self.name == "Youth") { return UIColor.colorWithHexString("#ba2420") }
        if (self.name == "Ruth's Kitchen") { return UIColor.colorWithHexString("#002157") }
        if (self.name == "City of Pensacola Events") { return UIColor.colorWithHexString("#2ae2b4") }
        if (self.name == "Scouting Ministries") { return UIColor.colorWithHexString("#2d590f") }
        if (self.name == "District and Conference Events") { return UIColor.colorWithHexString("#6995a3") }
        if (self.name == "Funerals") { return UIColor.colorWithHexString("#a8a8a8") }
        if (self.name == "Men's Ministries") { return UIColor.colorWithHexString("#6c974e") }
        if (self.name == "Methodist Children's Academy") { return UIColor.colorWithHexString("#dbccb0") }
        if (self.name == "Women's Ministries") { return UIColor.colorWithHexString("#6b0f7b") }
        if (self.name == "Outside and Community Events") { return UIColor.colorWithHexString("#b4d0a1") }
        
        return UIColor(white: 1, alpha: 0.9)
    }()
    var events = [CalendarEvent]()
    
    override init() {
        self.id = ""
        self.name = ""
    }
    
    init(jsonDictionary: NSDictionary) {
        self.id = jsonDictionary["id"] as String
        self.name = jsonDictionary["name"] as String
        if let colorString = jsonDictionary["colorString"] as? String {
            // self.color = UIColor.colorWithHexString(colorString)
        }
    }
   
}
