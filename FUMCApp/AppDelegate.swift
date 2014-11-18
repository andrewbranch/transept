//
//  AppDelegate.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit

extension UIImage {
    class func imageFromColor(color: UIColor, forSize size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Begin a new image that will be the new image with the rounded corners
        // (here with the size of an UIImageView)
        UIGraphicsBeginImageContext(size);
        
        // Draw your image
        image.drawInRect(rect)
        
        // Get the image, here setting the UIImageView image
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIColor {
    class func fumcRedColor() -> UIColor {
        return UIColor(red: 132/255, green: 21/255, blue: 33/255, alpha: 1)
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        var translucentWhite = UIColor(white: 0.95, alpha: 0.8)
        
        if let font = UIFont(name: "MyriadPro-Semibold", size: 18.0) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSFontAttributeName: font,
                NSForegroundColorAttributeName: UIColor.whiteColor()
            ]
        }
        
        if let font = UIFont(name: "MyriadPro-Regular", size: 18.0) {
            UIBarButtonItem.appearance().setTitleTextAttributes([
                NSFontAttributeName: font
            ], forState: UIControlState.Normal)
        }
        UIBarButtonItem.appearance().tintColor = translucentWhite
        
        if let font = UIFont(name: "MyriadPro-Regular", size: 10.0) {
            UITabBarItem.appearance().setTitleTextAttributes([
                NSFontAttributeName: font
            ], forState: UIControlState.Normal)
        }
        
        UINavigationBar.appearance().tintColor = translucentWhite
        UITabBar.appearance().selectedImageTintColor = UIColor.whiteColor()
        UITabBar.appearance().barTintColor = UIColor(white: 0.1, alpha: 1)
        UITabBar.appearance().selectionIndicatorImage = UIImage.imageFromColor(UIColor.blackColor(), forSize: CGSizeMake(UIScreen.mainScreen().bounds.width / 4, 49))
        
        Fabric.with([Twitter()])

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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

