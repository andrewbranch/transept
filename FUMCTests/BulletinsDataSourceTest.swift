//
//  BulletinsDataSourceTest.swift
//  FUMC
//
//  Created by Andrew Branch on 9/7/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import XCTest
import FUMC

class BulletinsDataSourceTest: XCTestCase {
    
    var dataSource: BulletinsDataSource?
    var tableView: UITableView?
    
    override func setUp() {
        super.setUp()
        self.dataSource = BulletinsDataSource(delegate: nil)
        self.tableView = UITableView()
        self.tableView!.registerNib(UINib(nibName: "MediaTableHeaderView", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "MediaTableHeaderViewIdentifier")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHeaderDateLabelText() {
        // Monday, September 7 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1441609200)
        
        let bulletin = [
            "id": "1",
            "attributes": [
                "liturgical-day": "Easter",
                "date": "2015-09-13T05:00:00.000Z",
                "service":"ICON",
                "visible": true,
                "file": "file.pdf"
            ]
        ]
        
        self.dataSource!.bulletins = [
            // Sunday, September 13 2015
            NSDate(timeIntervalSince1970: 1442127600): [try! Bulletin(jsonDictionary: bulletin, dateFormatter: NSDateFormatter())]
        ]
        
        let thisSundayHeader = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(thisSundayHeader.dateLabel!.text, "THIS SUNDAY, SEPTEMBER 13")
        
        // Saturday, September 5 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1441436400)
        let normalHeader = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(normalHeader.dateLabel!.text, "SUNDAY, SEPTEMBER 13")
        
        // Sunday, September 6 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1441522800)
        let nextHeader = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(nextHeader.dateLabel!.text, "NEXT SUNDAY, SEPTEMBER 13")
        
        // Sunday, September 13 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1442127900)
        let todayHeader = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(todayHeader.dateLabel!.text, "TODAY, SEPTEMBER 13")
        
        self.dataSource!.bulletins = [
            // Monday, September 14 2015
            NSDate(timeIntervalSince1970: 1442214000): [try! Bulletin(jsonDictionary: bulletin, dateFormatter: NSDateFormatter())]
        ]
        
        // Saturday, September 5 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1441436400)
        let normalHeader2 = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(normalHeader2.dateLabel!.text, "MONDAY, SEPTEMBER 14")
        
        // Monday, September 7 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1441609200)
        let nextHeader2 = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(nextHeader2.dateLabel!.text, "NEXT MONDAY, SEPTEMBER 14")
        
        // Tuesday, September 8 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1441695600)
        let nextHeader3 = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(nextHeader3.dateLabel!.text, "NEXT MONDAY, SEPTEMBER 14")
        
        // Sunday, September 13 2015
        self.dataSource!.referenceDate = NSDate(timeIntervalSince1970: 1442127900)
        let thisHeader = self.dataSource!.tableView(self.tableView!, viewForHeaderInSection: 0) as! MediaTableHeaderView
        XCTAssertEqual(thisHeader.dateLabel!.text, "THIS MONDAY, SEPTEMBER 14")
    }
    
}
