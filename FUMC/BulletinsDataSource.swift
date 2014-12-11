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
    var delegate: MediaTableViewDataSourceDelegate!
    var loading = false
    
    required init(delegate: MediaTableViewDataSourceDelegate) {
        super.init()
        self.delegate = delegate
        self.delegate.dataSourceDidStartLoadingAPI(self)
        requestData() {
            self.delegate.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func refresh() {
        requestData() {
            self.delegate.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestData(completed: () -> Void = { }) {
        self.loading = true
        API.shared().getBulletins() { bulletins, error in
            if (error != nil) {
                self.delegate.dataSource(self, failedToLoadWithError: error)
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
        return API.shared().fileURL(key: self.bulletinForIndexPath(indexPath).file)
    }
    
    func bulletinForIndexPath(indexPath: NSIndexPath) -> Bulletin {
        return self.bulletins[self.bulletins.keys.array.sorted(>)[indexPath.section]]![indexPath.row]
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.bulletins.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.bulletins.keys.array.isEmpty) { return 0 }
        return self.bulletins[self.bulletins.keys.array.sorted(>)[section]]!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        return self.dateFormatter.stringFromDate(self.bulletins.keys.array.sorted(>)[section])
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as UITableViewHeaderFooterView).textLabel.font = UIFont.fumcMainFontRegular14
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaTableViewCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.font = UIFont.fumcMainFontRegular16
        cell.textLabel!.text = self.bulletinForIndexPath(indexPath).service
        cell.detailTextLabel?.text = ""
        return cell
    }
    
}
