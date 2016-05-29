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
    @IBOutlet var instagramView: UIImageView?
    var border: CALayer?

    override func awakeFromNib() {
        self.border = CALayer()
        self.border!.frame = CGRectMake(0, self.frame.height - 1, self.superview?.frame.width ?? 1000, 1)
        self.border!.backgroundColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.layer.addSublayer(self.border!)

        self.facebookView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ConnectTableFooterView.tappedFacebook)))
        self.twitterView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ConnectTableFooterView.tappedTwitter)))
        self.vimeoView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ConnectTableFooterView.tappedVimeo)))
        self.instagramView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ConnectTableFooterView.tappedInstagram)))
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
    
    func tappedInstagram() {
        let instagramURL = NSURL(string: "instagram://user?username=fumcpensacola")
        if let url = instagramURL {
            if (UIApplication.sharedApplication().canOpenURL(url)) {
                UIApplication.sharedApplication().openURL(url)
                return
            }
        }
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://instagram.com/fumcpensacola")!)
    }
    
}
