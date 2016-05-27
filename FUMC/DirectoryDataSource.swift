//
//  DirectoryDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 5/26/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

public class DirectoryDataSource: NSObject, UITableViewDataSource {
    
    public var delegate: DirectoryDataSourceDelegate?
    public var title = "Directory"
    
    required public init(delegate: DirectoryDataSourceDelegate?) {
        super.init()
        self.delegate = delegate
    }
    
    public func refresh() {
        
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("directoryTableViewCell", forIndexPath: indexPath)
        cell.textLabel!.text = "It works"
        return cell
    }
}
