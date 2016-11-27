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
        self.dismissButton!.layer.borderColor = UIColor.white.cgColor
        self.dismissButton!.layer.borderWidth = 1
        self.dismissButton!.layer.cornerRadius = 10
        
        self.label!.textColor = UIColor.white
        self.label!.alpha = 1
        self.label!.isEnabled = true
        self.label!.textAlignment = NSTextAlignment.center
        self.label!.font = UIFont.fumcMainFontRegular26
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.standard.set(true, forKey: "knowsYouCanLiveStream")
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}
