//
//  NotificationBarButtonItem.swift
//  FUMC
//
//  Created by Andrew Branch on 11/26/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import BBBadgeBarButtonItem

protocol NotificationDelegate {
    func appDelegate(appDelegate: AppDelegate, didReceiveNotification notification: Notification) -> Void
    func applicationUpdatedBadgeCount(badgeCount: Int) -> Void
}

class NotificationBarButtonItem: BBBadgeBarButtonItem, NotificationDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var button = UIButton(frame: CGRectMake(0, 0, self.image!.size.width, self.image!.size.height))
        button.setImage(self.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        self.customView = button
        
        self.badgeBGColor   = UIColor.redColor()
        self.badgeTextColor = UIColor.whiteColor()
        self.badgeFont      = UIFont.systemFontOfSize(12)
        self.badgePadding   = 6
        self.badgeMinSize   = 8
        self.badgeOriginX   = 14
        self.badgeOriginY   = -8
        self.shouldHideBadgeAtZero = true
        self.shouldAnimateBadge = true
        self.customView!.clipsToBounds = false
        
        self.badgeValue = "\(UIApplication.sharedApplication().applicationIconBadgeNumber)"
        
        button.addTarget(self.target!, action: self.action, forControlEvents: UIControlEvents.TouchUpInside)
        
        (UIApplication.sharedApplication().delegate! as! AppDelegate).notificationDelegates.append(self)
    }
    
    func appDelegate(appDelegate: AppDelegate, didReceiveNotification notification: Notification) {
        self.badgeValue = "\(UIApplication.sharedApplication().applicationIconBadgeNumber)"
    }
    
    func applicationUpdatedBadgeCount(badgeCount: Int) {
        self.badgeValue = "\(badgeCount)"
    }

}
