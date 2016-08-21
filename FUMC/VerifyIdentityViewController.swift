//
//  VerifyIdentityViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 8/2/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import FBSDKLoginKit

protocol VerifyDelegate {
    func verifyViewController(viewController: VerifyIdentityViewController, got facebookToken: FBSDKAccessToken)
    func verifyViewController(viewController: VerifyIdentityViewController, failedWith error: NSError)
}

class VerifyIdentityViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookButtonContainer: UIView!
    @IBOutlet var twitterButtonContainer: UIView!
    var delegate: VerifyDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        let facebookButton = FBSDKLoginButton(frame: facebookButtonContainer.frame)
        facebookButton.delegate = self
        facebookButtonContainer.addSubview(facebookButton)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil && !result.isCancelled else {
            delegate.verifyViewController(self, failedWith: error)
            return
        }
        
        facebookButtonContainer.removeFromSuperview()
        delegate.verifyViewController(self, got: result.token)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        return
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
}
