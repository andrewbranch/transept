//
//  NSDateExtensionsTest.swift
//  FUMC
//
//  Created by Andrew Branch on 9/7/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import XCTest

class NSDateExtensionsTest: XCTestCase {
    
    func testDayOfWorkWeek() {
        let sunday = NSDate(timeIntervalSince1970: 1442127600)
        XCTAssertEqual(sunday.getComponent(NSCalendarUnit.Weekday), 1)
        XCTAssertEqual(sunday.dayOfWorkWeek(), 7)
        
        let monday = NSDate(timeIntervalSince1970: 1441609200)
        XCTAssertEqual(monday.getComponent(NSCalendarUnit.Weekday), 2)
        XCTAssertEqual(monday.dayOfWorkWeek(), 1)
    }
    
}
