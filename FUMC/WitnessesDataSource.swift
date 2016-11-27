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
    var delegate: MediaTableViewDataSourceDelegate?
    var witnesses = Dictionary<String, [Witness]>()
    var dateFormatter = DateFormatter()
    var loading = false
    
    required init(delegate: MediaTableViewDataSourceDelegate?) {
        super.init()
        self.dateFormatter.timeZone = TimeZone(abbreviation: "CST")
        self.delegate = delegate
    }
    
    func refresh() {
        self.delegate?.dataSourceDidStartLoadingAPI(self)
        requestData() {
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestData(_ completed: @escaping () -> Void = { }) {
        self.loading = true
        API.shared().getWitnesses() { witnesses, error in
            if (error != nil) {
                self.delegate?.dataSource(self, failedToLoadWithError: error)
            } else {
                self.witnesses.removeAll(keepCapacity: true)
                for w in witnesses.sorted(by: { a, b in a.from > b.from }) {
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
    
    func witnessForIndexPath(_ indexPath: IndexPath) -> Witness {
        return self.witnesses[self.witnesses.keys.sorted(by: >)[indexPath.section]]![indexPath.row]
    }
    
    func urlForIndexPath(_ indexPath: IndexPath) -> URL? {
        return API.shared().fileURL(key: self.witnessForIndexPath(indexPath).file as String) as URL?
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.witnesses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.witnesses.keys.isEmpty) { return 0 }
        return self.witnesses[self.witnesses.keys.sorted(by: >)[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.witnesses.keys.sorted(by: >)[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).textLabel!.font = UIFont.fumcMainFontRegular14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaTableViewCell", for: indexPath) as UITableViewCell
        let witness = self.witnessForIndexPath(indexPath)
        self.dateFormatter.dateFormat = "MMMM d"
        
        cell.textLabel!.font = UIFont.fumcMainFontRegular16
        cell.detailTextLabel?.font = UIFont.fumcMainFontRegular16
        
        cell.textLabel!.text = NSString(format: "Issue %i", witness.issue) as String
        cell.detailTextLabel!.text = NSString(format: "%@ – %@", self.dateFormatter.string(from: witness.from as Date), self.dateFormatter.string(from: witness.to as Date)) as String
        
        if (witness.to.midnight().addingTimeInterval(24 * 60 * 60 - 1) as Date > Date()) {
            cell.textLabel!.textColor = UIColor.fumcRedColor()
            cell.detailTextLabel!.textColor = UIColor.fumcRedColor().withAlphaComponent(0.5)
        }
        
        return cell
    }
    
}
