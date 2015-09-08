//
//  NotificationsDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 12/2/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import ZeroPush
import NSDate_TimeAgo

class NotificationsDataSource: NSObject, UITableViewDataSource {
    
    var title: NSString = "The Methodist Witness"
    var delegate: NotificationsDataSourceDelegate?
    var notifications = [Notification]()
    var url = NSURL(string: "https://fumc.herokuapp.com/api/notifications/current")
    var dateFormatter = NSDateFormatter()
    var readIds = [String]()
    var highlightedIds = [String]()
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
            self.requestData(channels.contains("testers")) {
                self.sortNotifications()
                self.delegate!.dataSourceDidFinishLoadingAPI(self)
            }
        }
    }
    
    override init() {
        super.init()
        self.getChannels() { channels in
            self.channels = channels
            self.requestData(channels.contains("testers")) {
                self.sortNotifications()
                self.delegate?.dataSourceDidFinishLoadingAPI(self)
            }
        }
    }
    
    func getChannels(completed: (channels: [String]) -> Void) {
        if (!ZeroPush.shared().deviceToken.isEmpty) {
            let request = NSURLRequest(URL: NSURL(string: "https://api.zeropush.com/devices/\(ZeroPush.shared().deviceToken)?auth_token=\(ZeroPush.shared().apiKey)")!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { respone, data, error in
                if (error != nil) {
                    completed(channels: [])
                    return
                }
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if let channels = json["channels"] as? [String] {
                        completed(channels: channels)
                    } else {
                        completed(channels: [])
                    }
                } catch {
                    completed(channels: [])
                }
            }
        } else {
            completed(channels: [])
        }
    }
    
    func refresh() {
        getChannels() { channels in
            self.channels = channels
            self.requestData(channels.contains("testers")) {
                self.sortNotifications()
                self.delegate?.dataSourceDidFinishLoadingAPI(self)
            }
        }
    }
    
    func requestData(tester: Bool, completed: () -> Void = { }) {
        API.shared().getNotifications(tester) { notifications, error in
            self.notifications = notifications
            completed()
        }
    }
    
    func incorporateNotificationFromPush(notification: Notification) {
        self.delegate?.tableView!.beginUpdates()
        self.notifications.append(notification)
        self.sortNotifications()
        self.delegate?.tableView!.insertRowsAtIndexPaths([indexPathForNotification(notification)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.delegate?.tableView!.endUpdates()
    }
    
    func sortNotifications() {
        self.notifications.sortInPlace {
            // TODO incompatible with iOS < 8.0
            NSCalendar.currentCalendar().compareDate($0.sendDate, toDate: $1.sendDate, toUnitGranularity: NSCalendarUnit.Second) == NSComparisonResult.OrderedDescending
        }
    }
    
    func notificationForIndexPath(indexPath: NSIndexPath) -> Notification {
        return self.notifications[indexPath.row]
    }
    
    func indexPathForNotification(notification: Notification) -> NSIndexPath {
        return NSIndexPath(forRow: self.notifications.indexOf(notification)!, inSection: 0)
    }
    
    func indexPathsForHighlightedCells() -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        for id in self.highlightedIds {
            indexPaths.appendContentsOf(self.notifications.filter({ $0.id == id }).map { NSIndexPath(forItem: self.notifications.indexOf($0)!, inSection: 0) })
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
        let cell = tableView.dequeueReusableCellWithIdentifier("notificationsTableViewCell", forIndexPath: indexPath) as! NotificationsTableViewCell
        let notification = notificationForIndexPath(indexPath)
        
        cell.unreadImageView!.hidden = self.readIds.contains(notification.id)
        cell.dateLabel!.text = notification.sendDate.timeAgo()
        cell.messageLabel!.attributedText = NSAttributedString(string: notification.message)
        cell.messageLabel!.font = UIFont.fumcMainFontRegular16
        cell.tintColor = UIColor.fumcNavyColor().colorWithAlphaComponent(0.5)
        
        if (self.highlightedIds.contains(notification.id)) {
            cell.backgroundColor = UIColor.fumcNavyColor().colorWithAlphaComponent(0.5)
        }
        
        if (!notification.url.isEmpty) {
            cell.accessoryView = UIImageView(image: self.linkImage)
        } else if let accessory = cell.accessoryView {
            accessory.removeFromSuperview()
            cell.accessoryView = nil
        }
        return cell
    }
   
}
