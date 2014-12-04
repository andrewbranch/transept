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
    
    required init(delegate: NotificationsDataSourceDelegate) {
        super.init()
        self.delegate = delegate
        self.delegate!.dataSourceDidStartLoadingAPI(self)
        requestData() {
            self.sortNotifications()
            self.delegate!.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    override init() {
        super.init()
        requestData() {
            self.sortNotifications()
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func refresh() {
        requestData() {
            self.sortNotifications()
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestData(completed: () -> Void = { }) {
        var request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil || (response as NSHTTPURLResponse).statusCode != 200) {
                return
            }
            
            var error: NSError?
            var notificationsDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as [NSDictionary]
            if (error != nil) {
                return
            }
            
            self.notifications.removeAll(keepCapacity: true)
            for (var i = 0; i < notificationsDictionaries.count; i++) {
                
                self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let sendDate = self.dateFormatter.dateFromString(notificationsDictionaries[i]["sendDate"] as String)
                let expirationDate = self.dateFormatter.dateFromString(notificationsDictionaries[i]["expirationDate"] as String)
                
                var n = Notification()
                n.id = notificationsDictionaries[i]["id"] as Int
                n.message = notificationsDictionaries[i]["message"] as String
                if let url = notificationsDictionaries[i]["url"] as? String {
                    n.url = url
                }
                n.sendDate = sendDate!
                n.expirationDate = expirationDate!
                
                self.notifications.append(n)
            }
            
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
            if let notification = self.notifications.filter({ $0.id == id }).first {
                if let index = find(self.notifications, notification) {
                    indexPaths.append(NSIndexPath(forItem: index, inSection: 0))
                }
            }
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
        
        cell.unreadImageView!.hidden = find(self.readIds, notification.id) != nil
        cell.dateLabel!.text = notification.sendDate.timeAgo()
        cell.messageLabel!.text = notification.message
        
        if (notification.url.isEmpty) {
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.userInteractionEnabled = false
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        }
        
        if (find(self.highlightedIds, notification.id) != nil) {
            cell.backgroundColor = UIColor.fumcNavyColor().colorWithAlphaComponent(0.2)
        }
        
        return cell
    }
   
}
