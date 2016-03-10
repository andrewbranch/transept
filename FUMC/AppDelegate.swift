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
import DigitsKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var serverReachability = Reachability(hostName: "api.fumcpensacola.com")
    var internetReachability = Reachability.reachabilityForInternetConnection()
    var bulletinsDataSource = BulletinsDataSource(delegate: nil)
    var witnessesDataSource = WitnessesDataSource(delegate: nil)
    var videosDataSource = VideosDataSource(delegate: nil)
    var rootViewController: RootTabBarController?
    
    #if DEBUG
    static let debug = true
    #else
    static let debug = false
    #endif

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
        UINavigationBar.appearance().translucent = false
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UITabBar.appearance().barTintColor = UIColor(white: 0.1, alpha: 1)
        UITabBar.appearance().selectionIndicatorImage = UIImage.imageFromColor(UIColor.blackColor(), forSize: CGSizeMake(UIScreen.mainScreen().bounds.width / 4, 49))
        
        Digits.sharedInstance().startWithConsumerKey(Env.get("DIGITS_CONSUMER_KEY")!, consumerSecret: Env.get("DIGITS_CONSUMER_SECRET")!)
        #if !DEBUG
        Fabric.with([Crashlytics(), Answers.self, Digits.self])
        #else
        Fabric.with([Digits.self])
        #endif
        
        

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
    }

    func applicationDidBecomeActive(application: UIApplication) {
        self.bulletinsDataSource.refresh()
        self.witnessesDataSource.refresh()
        self.videosDataSource.refresh()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

