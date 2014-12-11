//
//  MediaTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/13/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

protocol MediaTableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    var title: NSString { get }
    var loading: Bool { get }
    var delegate: MediaTableViewDataSourceDelegate! { get set }
    
    init(delegate: MediaTableViewDataSourceDelegate)
    func refresh() -> Void
    func urlForIndexPath(indexPath: NSIndexPath) -> NSURL?
}

protocol MediaTableViewDataSourceDelegate {
    func dataSourceDidStartLoadingAPI(dataSource: MediaTableViewDataSource) -> Void
    func dataSourceDidFinishLoadingAPI(dataSource: MediaTableViewDataSource) -> Void
    func dataSource(dataSource: MediaTableViewDataSource, failedToLoadWithError error: NSError?) -> Void
}

class MediaTableViewController: CustomTableViewController, MediaTableViewDataSourceDelegate {
    
    var dataSource: MediaTableViewDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title
        self.tableView!.dataSource = self.dataSource!
        self.tableView!.delegate = self.dataSource!
        
        self.tableView!.backgroundView?.hidden = self.dataSource!.loading || self.dataSource!.tableView(self.tableView!, numberOfRowsInSection: 0) > 0
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
    
    override func reloadData() {
        self.dataSource!.refresh()
    }
    
    
    // MARK: - MediaTableViewDataSourceDelegate
    
    func dataSourceDidStartLoadingAPI(dataSource: MediaTableViewDataSource) {
        self.showLoadingView()
    }
    
    func dataSourceDidFinishLoadingAPI(dataSource: MediaTableViewDataSource) {
        self.tableView!.reloadData()
        if (self.refreshControl.refreshing) {
            self.refreshControl.endRefreshing()
        } else {
            self.hideLoadingView()
        }
        
        self.tableView!.backgroundView?.hidden = dataSource.tableView(self.tableView!, numberOfRowsInSection: 0) > 0
    }
    
    func dataSource(dataSource: MediaTableViewDataSource, failedToLoadWithError error: NSError?) {
        ErrorAlerter.showLoadingAlertInViewController(self)
        dataSourceDidFinishLoadingAPI(self.dataSource!)
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "mediaTableCellSelection") {
            var viewController = segue.destinationViewController as MediaWebViewController
            var indexPath = self.tableView!.indexPathForSelectedRow()
            
            viewController.url = self.dataSource!.urlForIndexPath(indexPath!)
        }
    }

}
