//
//  AppDelegate.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ZeroPushDelegate, RKDropdownAlertDelegate {

    var window: UIWindow?
    var serverReachability = Reachability(hostName: "fumc.herokuapp.com")
    var internetReachability = Reachability.reachabilityForInternetConnection()
    var notificationDelegates = [NotificationDelegate]()
    var notificationsDataSource: NotificationsDataSource?
    var rootViewController: RootTabBarController?
    var notificationToShowOnLaunch: Notification?
    var notificationsViewIsOpen = false
    var featuredViewController: FeaturedViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
        let translucentWhite = UIColor(white: 0.95, alpha: 0.8)

        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.fumcMainFontBold18,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.fumcMainFontRegular18
        ], forState: UIControlState.Normal)
        UIBarButtonItem.appearance().tintColor = translucentWhite
        
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.fumcMainFontRegular10
        ], forState: UIControlState.Normal)
        
        UINavigationBar.appearance().barTintColor = UIColor.fumcRedColor()
        UINavigationBar.appearance().tintColor = translucentWhite
        UITabBar.appearance().selectedImageTintColor = UIColor.whiteColor()
        UITabBar.appearance().barTintColor = UIColor(white: 0.1, alpha: 1)
        UITabBar.appearance().selectionIndicatorImage = UIImage.imageFromColor(UIColor.blackColor(), forSize: CGSizeMake(UIScreen.mainScreen().bounds.width / 4, 49))
        
        Fabric.with([Crashlytics()])
        
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            self.notificationToShowOnLaunch = Notification(userInfo: userInfo)
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.notificationsDataSource!.refresh()
        for delegate in self.notificationDelegates {
            delegate.applicationUpdatedBadgeCount(UIApplication.sharedApplication().applicationIconBadgeNumber)
        }
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        #if DEBUG
        let apiKey = "psDtoDyjwcDbq6x8nYiZ"
        #else
        let apiKey = "zVr51xjJjiNgSBrHBMv5"
        #endif
        
        ZeroPush.engageWithAPIKey(apiKey, delegate: self)
        ZeroPush.shared().registerForRemoteNotifications()
        if let dataSource = self.notificationsDataSource {
            dataSource.refresh()
        } else {
            self.notificationsDataSource = NotificationsDataSource()
        }
        
        // Refresh every now and then
        if let featuredViewController = self.featuredViewController {
            featuredViewController.loadFeaturedContent()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        ZeroPush.shared().registerDeviceToken(deviceToken)
        NSLog(ZeroPush.deviceTokenFromData(deviceToken))
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog(error.description)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let notification = Notification(userInfo: userInfo)
        for delegate in self.notificationDelegates {
            delegate.appDelegate(self, didReceiveNotification: notification)
        }
        self.notificationsDataSource?.incorporateNotificationFromPush(notification)
        
        
        if (!self.notificationsViewIsOpen) {
            if (UIApplication.sharedApplication().applicationState != UIApplicationState.Active) {
                // App entered with notification
                self.rootViewController?.performSegueWithIdentifier("showNotifications", sender: [notification])
            } else {
                ZeroPush.shared().setBadge(UIApplication.sharedApplication().applicationIconBadgeNumber + 1)
                RKDropdownAlert.title("Tap to view", message: notification.message, backgroundColor: UIColor.fumcNavyColor(), textColor: UIColor.whiteColor(), time: 4, delegate: self, userInfo: notification)
            }
        }
    }
    
    func clearNotifications() {
        ZeroPush.shared().setBadge(0)
        for delegate in self.notificationDelegates {
            delegate.applicationUpdatedBadgeCount(0)
        }
    }
    
    func setBadgeCount(badgeCount: Int) {
        ZeroPush.shared().setBadge(badgeCount)
        for delegate in self.notificationDelegates {
            delegate.applicationUpdatedBadgeCount(badgeCount)
        }
    }

    func dropdownAlertWasTapped(alert: RKDropdownAlert!) -> Bool {
        self.rootViewController?.performSegueWithIdentifier("showNotifications", sender: [alert.userInfo as Notification])
        return true
    }

}

