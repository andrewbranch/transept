//
//  BulletinsDataSource.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/29/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import EZSwiftExtensions

open class BulletinsDataSource: NSObject, MediaTableViewDataSource {
    
    open var title: NSString = "Worship Bulletins"
    open var bulletins = Dictionary<Date, [Bulletin]>()
    open var delegate: MediaTableViewDataSourceDelegate?
    open var loading = false
    open var referenceDate = Date() // For overriding in tests
    let dateFormatter = DateFormatter()
    
    required public init(delegate: MediaTableViewDataSourceDelegate?) {
        super.init()
        self.dateFormatter.timeZone = TimeZone(abbreviation: "CST")
        self.delegate = delegate
    }
    
    open func refresh() {
        self.delegate?.dataSourceDidStartLoadingAPI(self)
        requestData() {
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestData(_ completed: @escaping () -> Void = { }) {
        self.referenceDate = Date()
        self.loading = true
        API.shared().getBulletins() { bulletins, error in
            if (error != nil) {
                self.delegate?.dataSource(self, failedToLoadWithError: error)
            } else {
                self.bulletins.removeAll(keepingCapacity: true)
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
    
    open func urlForIndexPath(_ indexPath: IndexPath) -> URL? {
        return API.shared().fileURL(key: self.bulletinForIndexPath(indexPath).file as String) as URL?
    }
    
    func bulletinForIndexPath(_ indexPath: IndexPath) -> Bulletin {
        return self.bulletins[self.bulletins.keys.sorted(by: >)[indexPath.section]]![indexPath.row]
    }
    
    // MARK: - Table view data source
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.bulletins.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.bulletins.keys.isEmpty) { return 0 }
        return self.bulletins[self.bulletins.keys.sorted(by: >)[section]]!.count
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MediaTableHeaderViewIdentifier") as! MediaTableHeaderView
        let date = self.bulletins.keys.sorted(by: >)[section]
        self.dateFormatter.dateFormat = "EEEE, MMMM d"
        let difference = date.midnight().timeIntervalSince(self.referenceDate.midnight())
        if (date.midnight() == self.referenceDate.midnight()) {
            self.dateFormatter.dateFormat = "'Today,' MMMM d"
        // Date is within the next seven days
        } else if (difference <= 7 * 24 * 60 * 60 && difference >= 0) {
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
        header.dateLabel!.text = self.dateFormatter.string(from: date).uppercased()
        header.liturgicalDayLabel!.text = self.bulletins[date]?[0].liturgicalDay
        
        return header
    }
    
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! MediaTableHeaderView
        if (headerView.dateLabel!.text!.hasPrefix("NEXT") || headerView.dateLabel!.text!.hasPrefix("THIS")) {
            headerView.dateLabel!.textColor = UIColor.fumcRedColor()
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaTableViewCell", for: indexPath) as UITableViewCell
        let bulletin = self.bulletinForIndexPath(indexPath)
        cell.textLabel!.font = UIFont.fumcMainFontRegular16
        cell.textLabel!.text = bulletin.service as String
        cell.detailTextLabel?.text = ""
        
        return cell
    }
    
}
