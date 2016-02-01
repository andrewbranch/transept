//
//  YouCanLiveStreamViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 1/31/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

class YouCanLiveStreamViewController: UIViewController {
    
    @IBOutlet var dismissButton: UIButton?
    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissButton!.layer.borderColor = UIColor.whiteColor().CGColor
        self.dismissButton!.layer.borderWidth = 1
        self.dismissButton!.layer.cornerRadius = 10
        
        self.label!.textColor = UIColor.whiteColor()
        self.label!.alpha = 1
        self.label!.enabled = true
        self.label!.textAlignment = NSTextAlignment.Center
        self.label!.font = UIFont.fumcMainFontRegular26
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "knowsYouCanLiveStream")
    }
    
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
