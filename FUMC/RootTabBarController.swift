//
//  RootTabBarController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/13/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    func knowsYouCanLiveStream() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("knowsYouCanLiveStream")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.sharedApplication().delegate as! AppDelegate).rootViewController = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !self.knowsYouCanLiveStream() {
            self.performSegueWithIdentifier("youCanLiveStreamNow", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
