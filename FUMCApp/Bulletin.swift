//
//  Bulletin.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/29/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Bulletin : NSObject {
    var id: Int
    var service: NSString
    var date: NSDate
    var file: NSString
    var visible: Bool
    
    override init() {
        self.id = 0
        self.service = ""
        self.date = NSDate()
        self.file = ""
        self.visible = false
    }
}
