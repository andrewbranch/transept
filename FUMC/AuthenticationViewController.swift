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
    func authenticationViewController(_ viewController: AuthenticationViewController, granted accessToken: AccessToken)
    func authenticationViewController(_ viewController: AuthenticationViewController, opened accessRequest: AccessRequest)
    func authenticationViewController(_ viewController: AuthenticationViewController, failedWith error: API.Error)
}

class AuthenticationViewController: UIPageViewController, ConfirmDelegate, VerifyDelegate {

    var authenticationDelegate: AuthenticationDelegate!
    var requestScopes: [API.Scopes]!
    
    fileprivate var accessToken: AccessToken?
    fileprivate var accessRequest: AccessRequest?
    
    init(delegate: AuthenticationDelegate, requestScopes: [API.Scopes], token: AccessToken?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        authenticationDelegate = delegate
        accessToken = token
        self.requestScopes = requestScopes
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let token = accessToken {
            confirmIdentity(token)
        } else {
            requestAccess(revokedToken: nil)
        }
    }
    
    fileprivate func confirmIdentity(_ token: AccessToken) {
        let confirmViewController = ConfirmIdentityViewController(nibName: "ConfirmIdentityViewController", bundle: nil)
        confirmViewController.delegate = self
        confirmViewController.firstName = token.user.firstName
        confirmViewController.lastName = token.user.lastName
        setViewControllers([confirmViewController], direction: .forward, animated: true, completion: nil)
    }
    
    fileprivate func requestAccess(revokedToken: AccessToken?) {
        guard let session = Digits.sharedInstance().session() else {
            authenticationDelegate.authenticationViewController(self, failedWith: API.Error.unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
            return
        }
        
        API.shared().requestAccess(session, scopes: self.requestScopes) { accessRequest in
            do {
                let request = try accessRequest.value()
                // Created access request.
                // Prompt to prove identity with Facebook or Twitter, or instruct to go to front office.
                self.accessRequest = request
                if let facebookToken = FBSDKAccessToken.current() {
                    self.updateAccessRequest(facebookToken)
                } else {
                    self.verifyIdentity(request)
                }
            } catch let error as API.Error {
                // Failed to create access request
                self.authenticationDelegate.authenticationViewController(self, failedWith: error)
            } catch {
                self.authenticationDelegate.authenticationViewController(self, failedWith: API.Error.unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
            }
        }
    }
    
    fileprivate func verifyIdentity(_ accessRequest: AccessRequest) {
        self.accessRequest = accessRequest
        let verifyViewController = VerifyIdentityViewController(nibName: "VerifyIdentityViewController", bundle: nil)
        verifyViewController.delegate = self
        setViewControllers([verifyViewController], direction: .forward, animated: true, completion: nil)
    }
    
    fileprivate func updateAccessRequest(_ facebookToken: FBSDKAccessToken) {
        guard let session = Digits.sharedInstance().session() else {
            authenticationDelegate.authenticationViewController(self, failedWith: API.Error.unknown(userMessage: nil, developerMessage: "Digits session was nil", userInfo: nil))
            return
        }
        
        API.shared().updateAccessRequest(self.accessRequest!, session: session, facebookToken: facebookToken.tokenString) { accessRequest in
            do {
                self.accessRequest = try accessRequest.value()
                self.authenticationDelegate.authenticationViewController(self, opened: self.accessRequest!)
            } catch let error as API.Error {
                self.authenticationDelegate.authenticationViewController(self, failedWith: error)
            } catch {
                self.authenticationDelegate.authenticationViewController(self, failedWith: API.Error.unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
            }
        }
    }
    
    func confirmViewControllerConfirmedIdentity(viewController: ConfirmIdentityViewController) {
        authenticationDelegate.authenticationViewController(self, granted: self.accessToken!)
    }
    
    func confirmViewControllerDeniedIdentity(viewController: ConfirmIdentityViewController) {
        // Revoke token and start access request process with some meta info describing phone number conflict
        API.shared().revoke(reason: "The user reported that they are not, in fact, \(accessToken!.user.fullName ?? "the person we matched them to"), despite being matched to that name in ACS by their phone number. A new access request is being opened, but the inconsistency needs to be fixed in ACS, and the token will have to be cleared or un-revoked manually.") { emptyResponse in
            do {
                try emptyResponse.value()
                self.requestAccess(revokedToken: self.accessToken)
            } catch let error as API.Error {
                self.authenticationDelegate.authenticationViewController(self, failedWith: error)
            } catch {
                self.authenticationDelegate.authenticationViewController(self, failedWith: API.Error.unknown(userMessage: nil, developerMessage: nil, userInfo: nil))
            }
        }
    }
    
    func verifyViewController(_ viewController: VerifyIdentityViewController, got facebookToken: FBSDKAccessToken) {
        updateAccessRequest(facebookToken)
    }
    
    func verifyViewControllerWillNotVerify(viewController: VerifyIdentityViewController) {
        // User wants to verify in person instead
        self.authenticationDelegate.authenticationViewController(self, opened: self.accessRequest!)
    }
    
    func verifyViewController(_ viewController: VerifyIdentityViewController, failedWith error: NSError) {
        authenticationDelegate.authenticationViewController(self, failedWith: API.Error.unknown(userMessage: nil, developerMessage: "Failed to log into Facebook", userInfo: nil))
    }

}
