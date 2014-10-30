//
//  MediaTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/13/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

protocol MediaTableViewDataSource: UITableViewDataSource {
    var title: NSString { get }
    var delegate: MediaTableViewDataSourceDelegate! { get set }
    
    init(delegate: MediaTableViewDataSourceDelegate)
    func urlForIndexPath(indexPath: NSIndexPath) -> NSURL?
}

protocol MediaTableViewDataSourceDelegate {
    func dataSourceDidFinishLoadingAPI(dataSource: MediaTableViewDataSource) -> Void
}

class MediaTableViewController: UITableViewController, MediaTableViewDataSourceDelegate {
    
    var dataSource: MediaTableViewDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.title = self.dataSource!.title
        self.tableView.dataSource = self.dataSource!
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow() {
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MediaTableViewDataSourceDelegate
    
    func dataSourceDidFinishLoadingAPI(dataSource: MediaTableViewDataSource) {
        self.tableView.reloadData()
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "mediaTableCellSelection") {
            var viewController = segue.destinationViewController as MediaWebViewController
            var indexPath = self.tableView.indexPathForSelectedRow()
            
            viewController.url = self.dataSource!.urlForIndexPath(indexPath!)
        }
    }

}
