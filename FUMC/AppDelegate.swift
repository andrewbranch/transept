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
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let USER_UNKNOWN_ERROR_MESSAGE = "Something went wrong. We’re looking into it!" // TODO make this not a lie

    var window: UIWindow?
    var serverReachability = Reachability(hostName: "api.fumcpensacola.com")
    var internetReachability = Reachability.forInternetConnection()
    var bulletinsDataSource = BulletinsDataSource(delegate: nil)
    var witnessesDataSource = WitnessesDataSource(delegate: nil)
    var videosDataSource = VideosDataSource(delegate: nil)
    var directoryDataSource = DirectoryDataSource(delegate: nil)
    var rootViewController: RootTabBarController?
    
    #if DEBUG
    static let debug = true
    #else
    static let debug = false
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        
        let translucentWhite = UIColor(white: 0.95, alpha: 0.8)

        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont.fumcMainFontBold18,
            NSForegroundColorAttributeName: UIColor.white
        ]

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.fumcMainFontRegular18
        ], for: UIControlState())
        UIBarButtonItem.appearance().tintColor = translucentWhite
        
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont.fumcMainFontRegular10
        ], for: UIControlState())
        
        UINavigationBar.appearance().barTintColor = UIColor.fumcRedColor()
        UINavigationBar.appearance().tintColor = translucentWhite
        UINavigationBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor(white: 0.1, alpha: 1)
        UITabBar.appearance().selectionIndicatorImage = UIImage.imageFromColor(UIColor.black, forSize: CGSize(width: UIScreen.main.bounds.width / 4, height: 49))
        
        Digits.sharedInstance().start(withConsumerKey: Env.get("DIGITS_CONSUMER_KEY")!, consumerSecret: Env.get("DIGITS_CONSUMER_SECRET")!)
        #if !DEBUG
        Fabric.with([Crashlytics(), Answers.self, Digits.self])
        #else
        Fabric.with([Digits.self])
        #endif
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.bulletinsDataSource.refresh()
        self.witnessesDataSource.refresh()
        self.videosDataSource.refresh()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

