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
    func verifyViewControllerWillNotVerify(viewController viewController: VerifyIdentityViewController)
    func verifyViewController(viewController: VerifyIdentityViewController, failedWith error: NSError)
}

class VerifyIdentityViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookButtonContainer: UIView!
    @IBOutlet var twitterButtonContainer: UIView!
    var delegate: VerifyDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        let facebookButton = FBSDKLoginButton(frame: CGRectZero)
        facebookButton.delegate = self
        facebookButtonContainer.addSubview(facebookButton)
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        facebookButtonContainer.addConstraints([
            NSLayoutConstraint(item: facebookButton, attribute: .CenterX, relatedBy: .Equal, toItem: facebookButtonContainer, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: facebookButtonContainer, attribute: .Bottom, relatedBy: .Equal, toItem: facebookButton, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: facebookButtonContainer, attribute: .Top, relatedBy: .Equal, toItem: facebookButton, attribute: .Top, multiplier: 1, constant: 0)
        ])
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
    
    @IBAction func tappedComeToFrontOffice() {
        delegate.verifyViewControllerWillNotVerify(viewController: self)
    }
}
