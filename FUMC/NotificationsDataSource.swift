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
                
                self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                let sendDateString = String(Array(notificationsDictionaries[i]["sendDate"] as String)[0...18]) + ".000Z"
                let sendDate = self.dateFormatter.dateFromString(sendDateString)
                let expirationDate = self.dateFormatter.dateFromString(notificationsDictionaries[i]["expirationDate"] as String)
                
                var n = Notification()
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
        self.notifications.append(notification)
        self.sortNotifications()
    }
    
    func sortNotifications() {
        self.notifications.sort {
            // TODO incompatible with iOS < 8.0
            NSCalendar.currentCalendar().compareDate($0.sendDate, toDate: $1.sendDate, toUnitGranularity: NSCalendarUnit.SecondCalendarUnit) == NSComparisonResult.OrderedAscending
        }
    }
    
    func notificationForIndexPath(indexPath: NSIndexPath) -> Notification {
        return self.notifications[indexPath.row]
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
        self.dateFormatter.dateFormat = "M/d/yyyy"
        
        cell.dateLabel!.text = self.dateFormatter.stringFromDate(notification.sendDate)
        cell.messageLabel!.text = notification.message
        return cell
    }
   
}
