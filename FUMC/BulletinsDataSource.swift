//
//  BulletinsDataSource.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/29/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

public class BulletinsDataSource: NSObject, MediaTableViewDataSource {
    
    public var title: NSString = "Worship Bulletins"
    public var bulletins = Dictionary<NSDate, [Bulletin]>()
    public var delegate: MediaTableViewDataSourceDelegate?
    public var loading = false
    public var referenceDate = NSDate() // For overriding in tests
    let dateFormatter = NSDateFormatter()
    
    required public init(delegate: MediaTableViewDataSourceDelegate?) {
        super.init()
        self.dateFormatter.timeZone = NSTimeZone(abbreviation: "CST")
        self.delegate = delegate
    }
    
    public func refresh() {
        self.delegate?.dataSourceDidStartLoadingAPI(self)
        requestData() {
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestData(completed: () -> Void = { }) {
        self.referenceDate = NSDate()
        self.loading = true
        API.shared().getBulletins() { bulletins, error in
            if (error != nil) {
                self.delegate?.dataSource(self, failedToLoadWithError: error)
            } else {
                self.bulletins.removeAll(keepCapacity: true)
                for b in bulletins {
                    if (self.bulletins.has(b.date)) {
                        self.bulletins[b.date]!.append(b)
                    } else {
                        self.bulletins[b.date] = [b]
                    }
                }
            }
            
            self.loading = false
            completed()
        }
    }
    
    public func urlForIndexPath(indexPath: NSIndexPath) -> NSURL? {
        return API.shared().fileURL(key: self.bulletinForIndexPath(indexPath).file as String)
    }
    
    func bulletinForIndexPath(indexPath: NSIndexPath) -> Bulletin {
        return self.bulletins[self.bulletins.keys.sort(>)[indexPath.section]]![indexPath.row]
    }
    
    // MARK: - Table view data source
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.bulletins.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.bulletins.keys.isEmpty) { return 0 }
        return self.bulletins[self.bulletins.keys.sort(>)[section]]!.count
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("MediaTableHeaderViewIdentifier") as! MediaTableHeaderView
        let date = self.bulletins.keys.sort(>)[section]
        self.dateFormatter.dateFormat = "EEEE, MMMM d"
        if (date.midnight() == self.referenceDate.midnight()) {
            self.dateFormatter.dateFormat = "'Today,' MMMM d"
        // Date is within the next seven days
        } else if (date.midnight() - self.referenceDate.midnight() <= 7 * 24 * 60 * 60 && date.midnight() - self.referenceDate.midnight() >= 0) {
            // People talk differently on Sundays (the whole next week is “this” until Sunday)
            if (self.referenceDate.dayOfWeek() == 1) {
                if (date.dayOfWeek() == 1) {
                    self.dateFormatter.dateFormat = "'Next' EEEE, MMMM d"
                } else {
                    self.dateFormatter.dateFormat = "'This' EEEE, MMMM d"
                }
            } else if (self.referenceDate.dayOfWorkWeek() < date.dayOfWorkWeek()) {
                self.dateFormatter.dateFormat = "'This' EEEE, MMMM d"
            } else {
                self.dateFormatter.dateFormat = "'Next' EEEE, MMMM d"
            }
        }
        header.dateLabel!.text = self.dateFormatter.stringFromDate(date).uppercaseString
        header.liturgicalDayLabel!.text = self.bulletins[date]?[0].liturgicalDay
        if let image = self.bulletins[date]?[0].previewImage {
            header.imageView!.image = image
        } else {
            header.imageView!.image = nil
        }
        
        return header
    }
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! MediaTableHeaderView
        if (headerView.dateLabel!.text!.hasPrefix("NEXT") || headerView.dateLabel!.text!.hasPrefix("THIS")) {
            headerView.dateLabel!.textColor = UIColor.fumcRedColor()
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaTableViewCell", forIndexPath: indexPath) as UITableViewCell
        let bulletin = self.bulletinForIndexPath(indexPath)
        cell.textLabel!.font = UIFont.fumcMainFontRegular16
        cell.textLabel!.text = bulletin.service as String
        cell.detailTextLabel?.text = ""
        
        return cell
    }
    
}
