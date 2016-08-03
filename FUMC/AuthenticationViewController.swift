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

class AuthenticationViewController: UIPageViewController, SignInDelegate, ConfirmDelegate, VerifyDelegate {

    var authenticationDelegate: AuthenticationDelegate!
    var requestScopes: [API.Scopes]!
    
    private var accessToken: AccessToken?
    
    init(requestScopes: [API.Scopes], delegate: AuthenticationDelegate) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.authenticationDelegate = delegate
        self.requestScopes = requestScopes
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Digits.sharedInstance().session() != nil {
            self.signIn()
        }
    }
    
    private func signIn() {
        let signInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        signInViewController.requestScopes = requestScopes
        signInViewController.delegate = self
        self.setViewControllers([signInViewController], direction: .Forward, animated: false, completion: nil)
    }
    
    private func confirmIdentity(token: AccessToken) {
        let confirmViewController = ConfirmIdentityViewController(nibName: "ConfirmIdentityViewController", bundle: nil)
        confirmViewController.delegate = self
        confirmViewController.firstName = token.user.firstName
        confirmViewController.lastName = token.user.lastName
        self.setViewControllers([confirmViewController], direction: .Forward, animated: true, completion: nil)
    }
    
    private func requestAccess(revokedToken revokedToken: AccessToken?) {
        do {
            guard let session = Digits.sharedInstance().session() else {
                throw API.Error.Unknown(userMessage: nil, developerMessage: nil, userInfo: nil)
            }
            
            try API.shared().requestAccess(session, scopes: self.requestScopes) { accessRequest in
                do {
                    let request = try accessRequest.value()
                    self.verifyIdentity(request)
                } catch let error as API.Error {
                    // Failed to create access request
                    self.authenticationDelegate.authenticationViewController(self, failedWith: error)
                } catch {
                    self.authenticationDelegate.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
                }
                // Created access request.
                // Prompt to prove identity with Facebook or Twitter, or instruct to go to front office.
                
                // Indicate that an access request is open.
                // applicationDidBecomeActive should check this and review the status of the request.
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "accessRequestOpen")
            }
        } catch let error as API.Error {
            // Failed to create access request
            self.authenticationDelegate.authenticationViewController(self, failedWith: error)
        } catch {
            self.authenticationDelegate.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
        }
    }
    
    private func verifyIdentity(accessRequest: AccessRequest) {
        let verifyViewController = VerifyIdentityViewController(nibName: "VerifyIdentityViewController", bundle: nil)
        self.setViewControllers([verifyViewController], direction: .Forward, animated: true, completion: nil)
    }
    
    func signInViewController(viewController: SignInViewController, grantedUnknownUser token: AccessToken) {
        self.accessToken = token
        self.confirmIdentity(token)
    }
    
    func signInViewController(viewController: SignInViewController, grantedKnownUser token: AccessToken) {
        self.accessToken = token
        self.authenticationDelegate.authenticationViewController(self, granted: token)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signInViewControllerCouldNotGrantToken(viewController viewController: SignInViewController) {
        requestAccess(revokedToken: nil)
    }
    
    func signInViewController(viewController: SignInViewController, failedWith error: NSError) {
        if let apiError = error as? API.Error {
            self.authenticationDelegate.authenticationViewController(self, failedWith: apiError)
        } else {
            self.authenticationDelegate.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
        }
    }
    
    func confirmViewControllerConfirmedIdentity(viewController viewController: ConfirmIdentityViewController) {
        self.authenticationDelegate.authenticationViewController(self, granted: self.accessToken!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func confirmViewControllerDeniedIdentity(viewController viewController: ConfirmIdentityViewController) {
        // Revoke token and start access request process with some meta info describing phone number conflict
    }
    
    func verifyViewController(viewController: VerifyIdentityViewController, got facebookToken: FBSDKAccessToken) {
        NSLog(facebookToken.tokenString)
    }
    
    func verifyViewController(viewController: VerifyIdentityViewController, failedWith error: NSError) {
        self.authenticationDelegate.authenticationViewController(self, failedWith: API.Error.Unknown(userMessage: nil, developerMessage: "Failed to log into Facebook", userInfo: nil))
    }

}
