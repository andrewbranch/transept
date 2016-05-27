//
//  RootTabBarController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/13/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        appDelegate.rootViewController = self
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if (viewController is DirectoryTableViewController) {
            (viewController as! DirectoryTableViewController).dataSource = appDelegate.directoryDataSource
        }
    }
}
