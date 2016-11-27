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
    func verifyViewController(_ viewController: VerifyIdentityViewController, got facebookToken: FBSDKAccessToken)
    func verifyViewControllerWillNotVerify(viewController: VerifyIdentityViewController)
    func verifyViewController(_ viewController: VerifyIdentityViewController, failedWith error: NSError)
}

class VerifyIdentityViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookButtonContainer: UIView!
    @IBOutlet var twitterButtonContainer: UIView!
    var delegate: VerifyDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        let facebookButton = FBSDKLoginButton(frame: CGRect.zero)
        facebookButton.delegate = self
        facebookButtonContainer.addSubview(facebookButton)
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        facebookButtonContainer.addConstraints([
            NSLayoutConstraint(item: facebookButton, attribute: .centerX, relatedBy: .equal, toItem: facebookButtonContainer, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: facebookButtonContainer, attribute: .bottom, relatedBy: .equal, toItem: facebookButton, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: facebookButtonContainer, attribute: .top, relatedBy: .equal, toItem: facebookButton, attribute: .top, multiplier: 1, constant: 0)
        ])
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil && !result.isCancelled else {
            delegate.verifyViewController(self, failedWith: error)
            return
        }
        
        facebookButtonContainer.removeFromSuperview()
        delegate.verifyViewController(self, got: result.token)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        return
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    @IBAction func tappedComeToFrontOffice() {
        delegate.verifyViewControllerWillNotVerify(viewController: self)
    }
}
