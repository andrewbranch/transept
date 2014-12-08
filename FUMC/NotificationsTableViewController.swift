//
//  NotificationsTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 11/26/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

protocol NotificationsDataSourceDelegate {
    var tableView: UITableView? { get set }
    func dataSourceDidStartLoadingAPI(dataSource: NotificationsDataSource) -> Void
    func dataSourceDidFinishLoadingAPI(dataSource: NotificationsDataSource) -> Void
}

class NotificationsTableViewController: CustomTableViewController, NotificationsDataSourceDelegate, UITableViewDelegate {
    
    var dataSource: NotificationsDataSource?
    
    override func awakeFromNib() {
        self.dataSource = (UIApplication.sharedApplication().delegate as AppDelegate).notificationsDataSource!
        self.dataSource!.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.dataSource = self.dataSource!
        self.tableView!.registerNib(UINib(nibName: "NotificationsTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "notificationsTableViewCell")
        self.tableView!.delegate = self
        self.refreshControl.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        if let readIds = NSUserDefaults.standardUserDefaults().objectForKey("readIds") as? [Int] {
            self.dataSource?.readIds = readIds
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        (UIApplication.sharedApplication().delegate! as AppDelegate).notificationsViewIsOpen = true
        for indexPath in self.dataSource!.indexPathsForHighlightedCells() {
            if let cell = self.tableView!.cellForRowAtIndexPath(indexPath) {
                UIView.animateWithDuration(0.5) {
                    cell.backgroundColor = UIColor.clearColor()
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        markAllAsRead()
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
    
    func markAllAsRead() {
        let appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
        appDelegate.clearNotifications()
        appDelegate.notificationsViewIsOpen = false
        NSUserDefaults.standardUserDefaults().setObject(self.dataSource!.notifications.map { $0.id }, forKey: "readIds")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = self.dataSource!.notificationForIndexPath(indexPath)
        if (find(self.dataSource!.readIds, notification.id) == nil) {
            self.dataSource!.readIds.append(notification.id)
            NSUserDefaults.standardUserDefaults().setObject(self.dataSource!.readIds, forKey: "readIds")
        }
        (UIApplication.sharedApplication().delegate as AppDelegate).setBadgeCount(UIApplication.sharedApplication().applicationIconBadgeNumber - 1)
        (self.tableView!.cellForRowAtIndexPath(indexPath) as NotificationsTableViewCell).unreadImageView!.hidden = true
        
        UIApplication.sharedApplication().openURL(NSURL(string: notification.url)!)
        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        struct Static {
            static var token: dispatch_once_t = 0
            static var sizingCell: NotificationsTableViewCell?
        }
        dispatch_once(&Static.token) {
            Static.sizingCell = tableView.dequeueReusableCellWithIdentifier("notificationsTableViewCell") as? NotificationsTableViewCell
        }
        
        self.dataSource!.setupCell(Static.sizingCell!, withNotification: self.dataSource!.notificationForIndexPath(indexPath))
        Static.sizingCell!.setNeedsLayout()
        Static.sizingCell!.layoutIfNeeded()
        return Static.sizingCell!.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 1
    }

}
