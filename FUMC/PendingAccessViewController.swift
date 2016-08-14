//
//  PendingAccessViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 8/13/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import DigitsKit
import FBSDKLoginKit

protocol PendingAccessDelegate {
    func pendingAccessViewController(viewController: PendingAccessViewController, granted accessToken: AccessToken)
    func pendingAccessViewController(viewController: PendingAccessViewController, failedWith error: NSError)
}

class PendingAccessViewController: UIViewController, SignInDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet var updatingView: UIView!
    @IBOutlet var approvedView: UIView!
    @IBOutlet var pendingWithIdentityView: UIView!
    @IBOutlet var pendingNeedsIdentityView: UIView!
    @IBOutlet var deniedView: UIView!
    @IBOutlet var facebookButtonContainer: UIView!
    
    var delegate: PendingAccessDelegate!
    var scopes: [API.Scopes]!
    var requestId: String!
    var accessToken: AccessToken?
    
    init(delegate: PendingAccessDelegate, scopes: [API.Scopes], accessRequestId: String) {
        super.init(nibName: "PendingAccessViewController", bundle: nil)
        self.delegate = delegate
        self.scopes = scopes
        self.requestId = accessRequestId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let facebookButton = FBSDKLoginButton(frame: facebookButtonContainer.frame)
        facebookButton.delegate = self
        facebookButtonContainer.addSubview(facebookButton)
        
        if let digitsSession = Digits.sharedInstance().session() {
            // Already signed into Digits
            API.shared().getAuthToken(digitsSession, scopes: self.scopes) { accessToken in
                do {
                    self.accessToken = try accessToken.value()
                    // Access Request must have been approved
                    API.shared().accessToken = self.accessToken!
                    // Show approvedView
                } catch API.Error.Unauthenticated {
                    // Access Request wasn’t approved; get status from server
                } catch let error as NSError {
                    self.delegate.pendingAccessViewController(self, failedWith: error)
                }
            }
        } else {
            let signInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
            signInViewController.delegate = self
            signInViewController.requestScopes = scopes
            self.presentViewController(signInViewController, animated: true, completion: nil)
        }
    }
    
    func signInViewController(viewController: SignInViewController, failedWith error: NSError) {
        self.delegate.pendingAccessViewController(self, failedWith: error)
    }
    
    func signInViewController(viewController: SignInViewController, grantedKnownUser token: AccessToken) {
        self.delegate.pendingAccessViewController(self, granted: token)
    }
    
    func signInViewController(viewController: SignInViewController, grantedUnknownUser token: AccessToken) {
        // This is impossible
        self.delegate.pendingAccessViewController(self, failedWith: NSError(domain: API.ERROR_DOMAIN, code: 3, userInfo: [
            "developerMessage": "PendingAccessViewController signed in but got an unknown user. Something is terribly wrong."
        ]))
    }
    
    func signInViewControllerCouldNotGrantToken(viewController viewController: SignInViewController) {
        // Access Request wasn’t approved; get status from server
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
        
        // Show pendingWithIdentityView
    }
    
    @IBAction func tappedGetStarted() {
        self.delegate.pendingAccessViewController(self, granted: accessToken!)
    }
}
