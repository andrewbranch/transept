//
//  SignInViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 7/31/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import DigitsKit

protocol SignInDelegate {
    func signInViewController(_ viewController: SignInViewController, grantedKnownUser token: AccessToken)
    func signInViewController(_ viewController: SignInViewController, grantedUnknownUser token: AccessToken)
    func signInViewControllerCouldNotGrantToken(viewController: SignInViewController)
    func signInViewController(_ viewController: SignInViewController, failedWith error: NSError)
}

class SignInViewController: UIViewController {

    @IBOutlet var signInButton: UIButton?
    var requestScopes: [API.Scopes]!
    var delegate: SignInDelegate!
    
    init(delegate: SignInDelegate, requestScopes: [API.Scopes]) {
        super.init(nibName: "SignInViewController", bundle: nil)
        self.delegate = delegate
        self.requestScopes = requestScopes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func didTapSignInButton() {
        signInButton!.isEnabled = false
        Digits.sharedInstance().authenticate { session, error in
            guard error == nil else {
                return self.delegate.signInViewController(self, failedWith: error as! NSError)
            }
            
            API.shared().getAuthToken(session!, scopes: self.requestScopes) { token in
                do {
                    let token = try token.value()
                    API.shared().accessToken = token
                    
                    // Logged in and has permission to read directory.
                    if (token.needsVerification) {
                        // New user, should confirm that identity is correct
                        self.delegate!.signInViewController(self, grantedUnknownUser: token)
                    } else {
                        // Known user, just hide the gate
                        self.delegate.signInViewController(self, grantedKnownUser: token)
                    }
                } catch API.Error.unauthorized {
                    // Could not grant requested scopes; start access request
                    self.delegate.signInViewControllerCouldNotGrantToken(viewController: self)
                } catch let error as NSError {
                    self.delegate.signInViewController(self, failedWith: error)
                }
            }
        }
    }
}
