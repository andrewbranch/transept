//
//  BulletinsDataSource.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/29/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class BulletinsDataSource: NSObject, MediaTableViewDataSource {
    
    var title: NSString = "Worship Bulletins"
    var bulletins = Dictionary<NSDate, [Bulletin]>()
    let dateFormatter = NSDateFormatter()
    var delegate: MediaTableViewDataSourceDelegate?
    var loading = false
    
    required init(delegate: MediaTableViewDataSourceDelegate?) {
        super.init()
        self.dateFormatter.timeZone = NSTimeZone(abbreviation: "CST")
        self.delegate = delegate
    }
    
    func refresh() {
        self.delegate?.dataSourceDidStartLoadingAPI(self)
        requestData() {
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestData(completed: () -> Void = { }) {
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
    
    func urlForIndexPath(indexPath: NSIndexPath) -> NSURL? {
        return API.shared().fileURL(key: self.bulletinForIndexPath(indexPath).file as String)
    }
    
    func bulletinForIndexPath(indexPath: NSIndexPath) -> Bulletin {
        return self.bulletins[self.bulletins.keys.sort(>)[indexPath.section]]![indexPath.row]
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.bulletins.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.bulletins.keys.isEmpty) { return 0 }
        return self.bulletins[self.bulletins.keys.sort(>)[section]]!.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("MediaTableHeaderViewIdentifier") as! MediaTableHeaderView
        let date = self.bulletins.keys.sort(>)[section]
        self.dateFormatter.dateFormat = "EEEE, MMMM d"
        if (date.midnight() - NSDate().midnight() <= 7 * 24 * 60 * 60 && date.midnight() - NSDate().midnight() >= 0) {
            if (date.dayOfWorkWeek() < NSDate().dayOfWorkWeek()) {
                self.dateFormatter.dateFormat = "'This' EEEE, MMMM d"
            } else {
                self.dateFormatter.dateFormat = "'Next' EEEE, MMMM d"
            }
        }
        header.dateLabel!.text = self.dateFormatter.stringFromDate(date).uppercaseString
        header.liturgicalDayLabel!.text = self.bulletins[date]?[0].liturgicalDay
        return header
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! MediaTableHeaderView
        if (headerView.dateLabel!.text!.hasPrefix("NEXT") || headerView.dateLabel!.text!.hasPrefix("THIS")) {
            headerView.dateLabel!.textColor = UIColor.fumcRedColor()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaTableViewCell", forIndexPath: indexPath) as UITableViewCell
        let bulletin = self.bulletinForIndexPath(indexPath)
        cell.textLabel!.font = UIFont.fumcMainFontRegular16
        cell.textLabel!.text = bulletin.service as String
        cell.detailTextLabel?.text = ""
        if let image = bulletin.previewImage {
            cell.imageView!.image = image
        }
        
        return cell
    }
    
}
