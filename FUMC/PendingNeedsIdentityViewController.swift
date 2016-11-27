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
    func pendingNeedsIdentity(viewController: PendingNeedsIdentityViewController, received token: FBSDKAccessToken)
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
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // This is impossible
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        // Don’t care
        return true
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard error == nil && !result.isCancelled else {
            return
        }
        
        delegate.pendingNeedsIdentity(viewController: self, received: result.token)
    }
}
