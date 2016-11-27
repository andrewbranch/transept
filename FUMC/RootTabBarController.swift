//
//  RootTabBarController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/13/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    fileprivate var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        appDelegate.rootViewController = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController is UINavigationController && (viewController as! UINavigationController).viewControllers[0] is DirectoryTableViewController) {
            ((viewController as! UINavigationController).viewControllers[0] as! DirectoryTableViewController).dataSource = appDelegate.directoryDataSource
        }
    }
}
