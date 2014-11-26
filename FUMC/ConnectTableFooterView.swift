//
//  ConnectTableFooterView.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/18/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class ConnectTableFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet var facebookView: UIImageView?
    @IBOutlet var twitterView: UIImageView?
    @IBOutlet var vimeoView: UIImageView?
    var border: CALayer?

    override func awakeFromNib() {
        self.border = CALayer()
        self.border!.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, 1)
        self.border!.backgroundColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.layer.addSublayer(self.border!)

        self.facebookView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedFacebook"))
        self.twitterView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedTwitter"))
        self.vimeoView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedVimeo"))
    }
    
    func tappedFacebook() {
        let facebookURL = NSURL(string: "fb://profile/120606361285987")
        if let url = facebookURL {
            if (UIApplication.sharedApplication().canOpenURL(url)) {
                UIApplication.sharedApplication().openURL(url)
                return
            }
        }
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/FUMCPensacola")!)
    }
    
    func tappedTwitter() {
        let twitterURL = NSURL(string: "twitter://user?screen_name=FUMCPensacola")
        if let url = twitterURL {
            if (UIApplication.sharedApplication().canOpenURL(url)) {
                UIApplication.sharedApplication().openURL(url)
                return
            }
        }
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/FUMCPensacola")!)
    }
    
    func tappedVimeo() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://vimeo.com/firstchurch")!)
    }
    
}
