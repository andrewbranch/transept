//
//  Witness.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/30/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class Witness: NSObject {
    
    var id: Int
    var from: NSDate
    var to: NSDate
    var file: NSString
    var volume: Int
    var issue: Int
    var visible: Bool
    
    override init() {
        self.id = 0
        self.from = NSDate()
        self.to = NSDate()
        self.volume = 0
        self.issue = 0
        self.file = ""
        self.visible = false
    }
}
