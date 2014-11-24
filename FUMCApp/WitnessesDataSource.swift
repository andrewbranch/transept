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
    var witnesses = Dictionary<NSString, [Witness]>()
    var url = NSURL(string: "https://fumc.herokuapp.com/api/witnesses?visible=true&orderBy=volume:Z,issue:Z")
    var dateFormatter = NSDateFormatter()
    
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
        var request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                // TODO
            } else {
                var witnessesDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as [NSDictionary]
                self.witnesses.removeAll(keepCapacity: true)
                for (var i = 0; i < witnessesDictionaries.count; i++) {
                    
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                    let from = self.dateFormatter.dateFromString(witnessesDictionaries[i].objectForKey("from") as String)
                    let to = self.dateFormatter.dateFromString(witnessesDictionaries[i].objectForKey("to") as String)
                    
                    var w = Witness()
                    w.setValuesForKeysWithDictionary(witnessesDictionaries[i])
                    w.from = from!
                    w.to = to!
                    
                    self.dateFormatter.dateFormat = "yyyy"
                    let volume = NSString(format: "%@ • Volume %i", self.dateFormatter.stringFromDate(w.from), w.volume)
                    if (self.witnesses.indexForKey(volume) != nil) {
                        self.witnesses[volume]!.append(w)
                    } else {
                        self.witnesses[volume] = [w]
                    }
                }
                
                completed()
            }
            
        }
    }
    
    func witnessForIndexPath(indexPath: NSIndexPath) -> Witness {
        return self.witnesses[self.witnesses.keys.array[indexPath.section]]![indexPath.row]
    }
    
    func urlForIndexPath(indexPath: NSIndexPath) -> NSURL? {
        return NSURL(string: "https://fumc.herokuapp.com/api/file/" + self.witnessForIndexPath(indexPath).file)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.witnesses.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.witnesses[self.witnesses.keys.array[section]]!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.witnesses.keys.array[section]
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let font = UIFont(name: "MyriadPro-Regular", size: 14) {
            (view as UITableViewHeaderFooterView).textLabel.font = font
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaTableViewCell", forIndexPath: indexPath) as UITableViewCell
        let witness = self.witnessForIndexPath(indexPath)
        self.dateFormatter.dateFormat = "MMMM d"
        
        if let font = UIFont(name: "MyriadPro-Regular", size: 16) {
            cell.textLabel.font = font
            cell.detailTextLabel?.font = font
        }
        
        cell.textLabel.text = NSString(format: "Issue %i", witness.issue)
        cell.detailTextLabel!.text = NSString(format: "%@ – %@", self.dateFormatter.stringFromDate(witness.from), self.dateFormatter.stringFromDate(witness.to))
        return cell
    }
    
}