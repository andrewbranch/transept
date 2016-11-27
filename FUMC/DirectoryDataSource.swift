//
//  DirectoryDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 5/26/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

open class DirectoryDataSource: NSObject, UITableViewDataSource {
    
    open var delegate: DirectoryDataSourceDelegate?
    open var title = "Directory"
    
    required public init(delegate: DirectoryDataSourceDelegate?) {
        super.init()
        self.delegate = delegate
    }
    
    open func refresh() {
        
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "directoryTableViewCell", for: indexPath)
        cell.textLabel!.text = "It works"
        return cell
    }
}
