//
//  AuthenticationViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 7/31/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import DigitsKit

protocol AuthenticationDelegate {
    func authenticationViewController(viewController: AuthenticationViewController, granted accessToken: AccessToken)
    func authenticationViewController(viewController: AuthenticationViewController, opened accessRequest: AccessRequest)
    func authenticationViewController(viewController: AuthenticationViewController, failedWith error: API.Error)
}

class AuthenticationViewController: UIViewController {

    @IBOutlet var signInButton: UIButton?
    var delegate: AuthenticationDelegate?
    var requestScopes: [API.Scopes]!
    
    @IBAction func didTapSignInButton() {
        signInButton!.enabled = false
        Digits.sharedInstance().authenticateWithCompletion { session, error in
            guard error == nil else {
                self.delegate?.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: "Digits authentication failed", userInfo: nil))
                return
            }
            
            do {
                try API.shared().getAuthToken(session, scopes: self.requestScopes) { token in
                    do {
                        let token = try token.value()
                        API.shared().accessToken = token
                        
                        // Logged in and has permission to read directory.
                        if (token.needsVerification) {
                            // New user, should confirm that identity is correct
                        } else {
                            // Known user, just hide the gate
                            self.dismissViewControllerAnimated(true) {
                                self.delegate?.authenticationViewController(self, granted: token)
                            }
                        }
                    } catch API.Error.Unauthorized {
                        // Could not grant requested scopes; start access request
                        do {
                            try API.shared().requestAccess(self.requestScopes) { accessRequest in
                                // Created access request.
                                // Prompt to prove identity with Facebook or Twitter, or instruct to go to front office.
                                
                                // Indicate that an access request is open.
                                // applicationDidBecomeActive should check this and review the status of the request.
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "accessRequestOpen")
                            }
                        } catch let error as API.Error {
                            // Failed to create access request
                            self.delegate?.authenticationViewController(self, failedWith: error)
                        } catch {
                            self.delegate?.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: "Unknown error creating access request", userInfo: nil))
                        }
                    } catch let error as API.Error {
                        self.delegate?.authenticationViewController(self, failedWith: error)
                    } catch {
                        self.delegate?.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: "Unknown error requesting auth token", userInfo: nil))
                    }
                }
            } catch let error as API.Error {
                self.delegate?.authenticationViewController(self, failedWith: error)
            } catch {
                self.delegate?.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: "Unknown error requesting auth token", userInfo: nil))
            }
        }
    }

}
