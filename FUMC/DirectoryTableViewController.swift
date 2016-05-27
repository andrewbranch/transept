//
//  DirectoryTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 5/26/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

public protocol DirectoryDataSourceDelegate {
    
}

class DirectoryTableViewController: CustomTableViewController, DirectoryDataSourceDelegate {
    
    var dataSource: DirectoryDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title as String
        self.tableView!.dataSource = self.dataSource!
    }
}
