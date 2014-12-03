//
//  NotificationsTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 11/26/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

@objc protocol NotificationsDataSourceDelegate {
    func dataSourceDidStartLoadingAPI(dataSource: NotificationsDataSource) -> Void
    func dataSourceDidFinishLoadingAPI(dataSource: NotificationsDataSource) -> Void
}

class NotificationsTableViewController: CustomTableViewController, NotificationsDataSourceDelegate {
    
    var dataSource: NotificationsDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = (UIApplication.sharedApplication().delegate as AppDelegate).notificationsDataSource!
        self.dataSource!.delegate = self
        self.tableView!.dataSource = self.dataSource!
        self.tableView!.registerNib(UINib(nibName: "NotificationsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "notificationsTableViewCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        (UIApplication.sharedApplication().delegate! as AppDelegate).clearNotifications()
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func reloadData() {
        (self.tableView!.dataSource! as NotificationsDataSource).refresh()
    }
    
    func dataSourceDidStartLoadingAPI(dataSource: NotificationsDataSource) {
        self.showLoadingView()
    }
    
    func dataSourceDidFinishLoadingAPI(dataSource: NotificationsDataSource) {
        self.tableView!.reloadData()
        if (self.refreshControl.refreshing) {
            self.refreshControl.endRefreshing()
        } else {
            self.hideLoadingView()
        }
    }

}
