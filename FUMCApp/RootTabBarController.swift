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
        
        var homeItem = self.tabBar.items?[0] as UITabBarItem
        var mediaItem = self.tabBar.items?[1] as UITabBarItem
        var giveItem = self.tabBar.items?[2] as UITabBarItem
        var connectItem = self.tabBar.items?[3] as UITabBarItem
        
        homeItem.selectedImage = UIImage(named: "home-selected")
        mediaItem.selectedImage = UIImage(named: "media-selected")
        giveItem.selectedImage = UIImage(named: "give-selected")
        connectItem.selectedImage = UIImage(named: "connect-selected")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
