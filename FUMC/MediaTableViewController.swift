//
//  MediaTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/13/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import Crashlytics

public protocol MediaTableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    var title: NSString { get }
    var loading: Bool { get }
    var delegate: MediaTableViewDataSourceDelegate? { get set }
    
    init(delegate: MediaTableViewDataSourceDelegate?)
    func refresh() -> Void
    func urlForIndexPath(indexPath: NSIndexPath) -> NSURL?
}

public protocol MediaTableViewDataSourceDelegate {
    func dataSourceDidStartLoadingAPI(dataSource: MediaTableViewDataSource) -> Void
    func dataSourceDidFinishLoadingAPI(dataSource: MediaTableViewDataSource) -> Void
    func dataSource(dataSource: MediaTableViewDataSource, failedToLoadWithError error: ErrorType?) -> Void
}

public class MediaTableViewController: CustomTableViewController, MediaTableViewDataSourceDelegate {
    
    var dataSource: MediaTableViewDataSource?

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title as String
        self.tableView!.dataSource = self.dataSource!
        self.tableView!.delegate = self.dataSource!
        
        self.tableView!.backgroundView?.hidden = self.dataSource!.loading || self.dataSource!.tableView(self.tableView!, numberOfRowsInSection: 0) > 0
        
        self.tableView!.registerNib(UINib(nibName: "MediaTableHeaderView", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "MediaTableHeaderViewIdentifier")
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEventWithName("Viewed media list", customAttributes: [
            "Name": self.dataSource?.title ?? ""
        ])
        #endif
    }
    
    override func reloadData() {
        self.showLoadingView()
        self.dataSource!.refresh()
    }
    
    // MARK: - MediaTableViewDataSourceDelegate
    
    public func dataSourceDidStartLoadingAPI(dataSource: MediaTableViewDataSource) {
        self.showLoadingView()
    }
    
    public func dataSourceDidFinishLoadingAPI(dataSource: MediaTableViewDataSource) {
        self.tableView!.reloadData()
        self.tableViewController.refreshControl!.endRefreshing()
        self.hideLoadingView()
        
        self.tableView!.backgroundView?.hidden = dataSource.tableView(self.tableView!, numberOfRowsInSection: 0) > 0
    }
    
    public func dataSource(dataSource: MediaTableViewDataSource, failedToLoadWithError error: ErrorType?) {
        ErrorAlerter.showLoadingAlertInViewController(self)
        dataSourceDidFinishLoadingAPI(self.dataSource!)
    }


    // MARK: - Navigation

    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "mediaTableCellSelection") {
            let viewController = segue.destinationViewController as! MediaWebViewController
            let indexPath = self.tableView!.indexPathForSelectedRow
            
            viewController.url = self.dataSource!.urlForIndexPath(indexPath!)
            #if !DEBUG
            Answers.logCustomEventWithName("Viewed media item", customAttributes: [
                "Kind": self.dataSource?.title ?? "",
                "URL": viewController.url?.absoluteString ?? ""
            ])
            #endif
        }
    }

}
