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
    func signInViewController(viewController: SignInViewController, grantedKnownUser token: AccessToken)
    func signInViewController(viewController: SignInViewController, grantedUnknownUser token: AccessToken)
    func signInViewControllerCouldNotGrantToken(viewController viewController: SignInViewController)
    func signInViewController(viewController: SignInViewController, failedWith error: NSError)
}

class SignInViewController: UIViewController {

    @IBOutlet var signInButton: UIButton?
    var requestScopes: [API.Scopes]!
    var delegate: SignInDelegate!
    
    @IBAction func didTapSignInButton() {
        signInButton!.enabled = false
        Digits.sharedInstance().authenticateWithCompletion { session, error in
            guard error == nil else {
                return self.delegate.signInViewController(self, failedWith: error)
            }
            
            API.shared().getAuthToken(session, scopes: self.requestScopes) { token in
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
                } catch API.Error.Unauthorized {
                    // Could not grant requested scopes; start access request
                    self.delegate.signInViewControllerCouldNotGrantToken(viewController: self)
                } catch let error as NSError {
                    self.delegate.signInViewController(self, failedWith: error)
                }
            }
        }
    }
}
