//
//  NotificationsDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 12/2/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class NotificationsDataSource: NSObject, UITableViewDataSource {
    
    var title: NSString = "The Methodist Witness"
    var delegate: NotificationsDataSourceDelegate?
    var notifications = [Notification]()
    var url = NSURL(string: "https://fumc.herokuapp.com/api/notifications/current")
    var dateFormatter = NSDateFormatter()
    var readIds = [Int]()
    var highlightedIds = [Int]()
    var channels = [String]()
    lazy var linkImage: UIImage = {
        return UIImage(named: "link")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }()
    
    required init(delegate: NotificationsDataSourceDelegate) {
        super.init()
        self.delegate = delegate
        self.delegate!.dataSourceDidStartLoadingAPI(self)
        
        self.getChannels() { channels in
            self.channels = channels
            self.requestData(channels.contains("tester")) {
                self.sortNotifications()
                self.delegate!.dataSourceDidFinishLoadingAPI(self)
            }
        }
    }
    
    override init() {
        super.init()
        self.getChannels() { channels in
            self.channels = channels
            self.requestData(channels.contains("tester")) {
                self.sortNotifications()
                self.delegate?.dataSourceDidFinishLoadingAPI(self)
            }
        }
    }
    
    func getChannels(completed: (channels: [String]) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: "https://api.zeropush.com/devices/\(ZeroPush.shared().deviceToken)?auth_token=\(ZeroPush.shared().apiKey)")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { respone, data, error in
            if (error != nil) {
                completed(channels: [])
                return
            }
            var error: NSError?
            let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as NSDictionary
            if (error == nil) {
                completed(channels: json["channels"] as [String])
            } else {
                completed(channels: [])
            }
        }
    }
    
    func refresh() {
        requestData(self.channels.contains("tester")) {
            self.sortNotifications()
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestData(tester: Bool, completed: () -> Void = { }) {
        API.shared().getNotifications(tester) { notifications, error in
            self.notifications = notifications
            completed()
        }
    }
    
    func incorporateNotificationFromPush(notification: Notification) {
        self.delegate?.tableView?.beginUpdates()
        self.notifications.append(notification)
        self.sortNotifications()
        self.delegate?.tableView?.insertRowsAtIndexPaths([indexPathForNotification(notification)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.delegate?.tableView?.endUpdates()
    }
    
    func sortNotifications() {
        self.notifications.sort {
            // TODO incompatible with iOS < 8.0
            NSCalendar.currentCalendar().compareDate($0.sendDate, toDate: $1.sendDate, toUnitGranularity: NSCalendarUnit.SecondCalendarUnit) == NSComparisonResult.OrderedDescending
        }
    }
    
    func notificationForIndexPath(indexPath: NSIndexPath) -> Notification {
        return self.notifications[indexPath.row]
    }
    
    func indexPathForNotification(notification: Notification) -> NSIndexPath {
        return NSIndexPath(forRow: find(self.notifications, notification)!, inSection: 0)
    }
    
    func indexPathsForHighlightedCells() -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        for id in self.highlightedIds {
            indexPaths.extend(self.notifications.filter({ $0.id == id }).map { NSIndexPath(forItem: self.notifications.indexOf($0)!, inSection: 0) })
        }
        self.highlightedIds.removeAll(keepCapacity: false)
        return indexPaths
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notificationsTableViewCell", forIndexPath: indexPath) as NotificationsTableViewCell
        let notification = notificationForIndexPath(indexPath)
        
        if (!notification.url.isEmpty) {
            cell.accessoryView = UIImageView(image: self.linkImage)
        } else if let accessory = cell.accessoryView {
            accessory.removeFromSuperview()
            cell.accessoryView = nil
        }
        return cell
    }
   
}
