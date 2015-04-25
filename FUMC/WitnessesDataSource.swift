//
//  WitnessesDataSource.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/30/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class WitnessesDataSource: NSObject, MediaTableViewDataSource {
    
    var title: NSString = "The Methodist Witness"
    var delegate: MediaTableViewDataSourceDelegate!
    var witnesses = Dictionary<String, [Witness]>()
    var dateFormatter = NSDateFormatter()
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
        API.shared().getWitnesses() { witnesses, error in
            if (error != nil) {
                self.delegate.dataSource(self, failedToLoadWithError: error)
            } else {
                self.witnesses.removeAll(keepCapacity: true)
                for w in witnesses.sorted({ a, b in a.from > b.from }) {
                    let sectionTitle = "\(w.from.year) • Volume \(w.volume)"
                    if (self.witnesses.has(sectionTitle)) {
                        self.witnesses[sectionTitle]!.append(w)
                    } else {
                        self.witnesses[sectionTitle] = [w]
                    }
                }

            }
            
            self.loading = false
            completed()
        }
    }
    
    func witnessForIndexPath(indexPath: NSIndexPath) -> Witness {
        return self.witnesses[self.witnesses.keys.array.sorted(>)[indexPath.section]]![indexPath.row]
    }
    
    func urlForIndexPath(indexPath: NSIndexPath) -> NSURL? {
        return API.shared().fileURL(key: self.witnessForIndexPath(indexPath).file as String)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.witnesses.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.witnesses.keys.array.isEmpty) { return 0 }
        return self.witnesses[self.witnesses.keys.array.sorted(>)[section]]!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.witnesses.keys.array.sorted(>)[section]
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel.font = UIFont.fumcMainFontRegular14
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        let witness = self.witnessForIndexPath(indexPath)
        self.dateFormatter.dateFormat = "MMMM d"
        
        cell.textLabel!.font = UIFont.fumcMainFontRegular16
        cell.detailTextLabel?.font = UIFont.fumcMainFontRegular16
        
        cell.textLabel!.text = NSString(format: "Issue %i", witness.issue) as String
        cell.detailTextLabel!.text = NSString(format: "%@ – %@", self.dateFormatter.stringFromDate(witness.from), self.dateFormatter.stringFromDate(witness.to)) as String
        
        if (witness.to.midnight().dateByAddingTimeInterval(24 * 60 * 60 - 1) > NSDate()) {
            cell.textLabel!.textColor = UIColor.fumcRedColor()
            cell.detailTextLabel!.textColor = UIColor.fumcRedColor().colorWithAlphaComponent(0.5)
        }
        
        return cell
    }
    
}