//
//  GiveViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import Crashlytics
import DigitsKit
import Locksmith

class GiveViewController: UIViewController {
    
    @IBOutlet var header: UIChangingLabel?
    @IBOutlet var textLabel: UILabel?
    @IBOutlet var button: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.header!.label.textColor = UIColor.fumcMagentaColor()
        self.header!.label.alpha = 1
        self.header!.label.enabled = true
        self.header!.label.textAlignment = NSTextAlignment.Center
        self.header!.label.font = UIFont.fumcMainFontRegular26
        self.header!.texts = [
            "with a cheerful heart",
            "out of love",
            "from a spirit of thanks"
        ]
        
        self.textLabel!.font = UIFont.fumcMainFontRegular16
        
        self.button!.layer.borderColor = UIColor.fumcMagentaColor().CGColor
        self.button!.layer.borderWidth = 2
        self.button!.layer.cornerRadius = 10
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEventWithName("Viewed tab", customAttributes: ["Name": "Give"])
        #endif
    }
    
    @IBAction func give() {
        #if !DEBUG
        Answers.logCustomEventWithName("Tapped “Give”", customAttributes: nil)
        #endif
        UIApplication.sharedApplication().openURL(NSURL(string: "http://fumcpensacola.com/www/welcomenews/givingpayments")!)
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
