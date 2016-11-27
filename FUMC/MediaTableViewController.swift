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
    func urlForIndexPath(_ indexPath: IndexPath) -> URL?
}

public protocol MediaTableViewDataSourceDelegate {
    func dataSourceDidStartLoadingAPI(_ dataSource: MediaTableViewDataSource) -> Void
    func dataSourceDidFinishLoadingAPI(_ dataSource: MediaTableViewDataSource) -> Void
    func dataSource(_ dataSource: MediaTableViewDataSource, failedToLoadWithError error: Error?) -> Void
}

open class MediaTableViewController: CustomTableViewController, MediaTableViewDataSourceDelegate {
    
    var dataSource: MediaTableViewDataSource?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title as String
        self.tableView!.dataSource = self.dataSource!
        self.tableView!.delegate = self.dataSource!
        
        self.tableView!.backgroundView?.isHidden = self.dataSource!.loading || self.dataSource!.tableView(self.tableView!, numberOfRowsInSection: 0) > 0
        
        self.tableView!.register(UINib(nibName: "MediaTableHeaderView", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "MediaTableHeaderViewIdentifier")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRow(at: indexPath, animated: true)
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEvent(withName: "Viewed media list", customAttributes: [
            "Name": self.dataSource?.title ?? ""
        ])
        #endif
    }
    
    override func reloadData() {
        self.showLoadingView()
        self.dataSource!.refresh()
    }
    
    // MARK: - MediaTableViewDataSourceDelegate
    
    open func dataSourceDidStartLoadingAPI(_ dataSource: MediaTableViewDataSource) {
        self.showLoadingView()
    }
    
    open func dataSourceDidFinishLoadingAPI(_ dataSource: MediaTableViewDataSource) {
        self.tableView!.reloadData()
        self.tableViewController.refreshControl!.endRefreshing()
        self.hideLoadingView()
        
        self.tableView!.backgroundView?.isHidden = dataSource.tableView(self.tableView!, numberOfRowsInSection: 0) > 0
    }
    
    open func dataSource(_ dataSource: MediaTableViewDataSource, failedToLoadWithError error: Error?) {
        ErrorAlerter.showLoadingAlertInViewController(self)
        dataSourceDidFinishLoadingAPI(self.dataSource!)
    }


    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "mediaTableCellSelection") {
            let viewController = segue.destination as! MediaWebViewController
            let indexPath = self.tableView!.indexPathForSelectedRow
            
            viewController.url = self.dataSource!.urlForIndexPath(indexPath!)
            #if !DEBUG
            Answers.logCustomEvent(withName: "Viewed media item", customAttributes: [
                "Kind": self.dataSource?.title ?? "",
                "URL": viewController.url?.absoluteString ?? ""
            ])
            #endif
        }
    }

}
