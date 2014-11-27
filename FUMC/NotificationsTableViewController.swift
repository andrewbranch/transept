//
//  NotificationsTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 11/26/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

class NotificationsTableViewController: UITableViewController {
    
    override func viewDidAppear(animated: Bool) {
        (UIApplication.sharedApplication().delegate! as AppDelegate).clearNotifications()
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
