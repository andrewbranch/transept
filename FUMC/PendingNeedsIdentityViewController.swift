//
//  PendingNeedsIdentityViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 10/31/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import FBSDKLoginKit

protocol PendingNeedsIdentityDelegate {
    func pendingNeedsIdentity(viewController viewController: PendingNeedsIdentityViewController, received token: FBSDKAccessToken)
}

class PendingNeedsIdentityViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var facebookButtonContainer: UIView!
    var delegate: PendingNeedsIdentityDelegate!
    
    init(delegate: PendingNeedsIdentityDelegate) {
        super.init(nibName: "PendingNeedsIdentityViewController", bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // This is impossible
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        // Don’t care
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil && !result.isCancelled else {
            return
        }
        
        delegate.pendingNeedsIdentity(viewController: self, received: result.token)
    }
}
