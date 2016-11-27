//
//  BulletinTest.swift
//  FUMC
//
//  Created by Andrew Branch on 9/6/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import XCTest
import FUMC

class BulletinTest: XCTestCase {
    
    func testBulletinInit() {
        let badData = [
            "id": "1",
            "attributes": [
                "liturgical-day": "Easter",
                "date": "2015-08-23T05:00:00.000Z",
                "service":"ICON",
                "visible": true
            ]
        ] as [String : Any]
        
        let bad = try? Bulletin(jsonDictionary: badData, dateFormatter: DateFormatter())
        XCTAssertNil(bad, "Should throw when file not present")
        
        let goodData = [
            "id": "1",
            "attributes": [
                "liturgical-day": "Easter",
                "date": "2015-08-23T05:00:00.000Z",
                "service":"ICON",
                "visible": true,
                "file": "file.pdf"
            ]
        ] as [String : Any]
        
        let good = try? Bulletin(jsonDictionary: goodData, dateFormatter: DateFormatter())
        XCTAssertNotNil(good, "Should initialize")
    }
    
}
