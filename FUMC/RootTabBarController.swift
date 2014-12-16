//
//  RootTabBarController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/13/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.sharedApplication().delegate as AppDelegate).rootViewController = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let launchNotification = appDelegate.notificationToShowOnLaunch {
            self.performSegueWithIdentifier("showNotifications", sender: [launchNotification])
            appDelegate.notificationToShowOnLaunch = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showNotifications") {
            let viewController = (segue.destinationViewController as UINavigationController).viewControllers.first! as NotificationsTableViewController
            for n in sender as [Notification] {
                if (!viewController.dataSource!.notifications.contains(n)) {
                    viewController.dataSource!.incorporateNotificationFromPush(n)
                }
            }
            viewController.dataSource!.highlightedIds = (sender as [Notification]).map { $0.id }
        }
    }

}
