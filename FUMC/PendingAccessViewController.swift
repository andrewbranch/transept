//
//  PendingAccessViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 8/13/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import DigitsKit

protocol PendingAccessDelegate {
    func pendingAccessViewController(viewController: PendingAccessViewController, granted accessToken: AccessToken)
    func pendingAccessViewController(viewController: PendingAccessViewController, failedWith error: NSError)
}

class PendingAccessViewController: UIPageViewController, SignInDelegate, PendingNeedsIdentityDelegate, ApprovedDelegate {
    var accessDelegate: PendingAccessDelegate!
    var scopes: [API.Scopes]!
    var requestId: String!
    var accessRequest: AccessRequest?
    var accessToken: AccessToken?
    let updatingViewController = UIViewController(nibName: "UpdatingViewController", bundle: nil)
    lazy var pendingWithIdentityViewController = { return UIViewController(nibName: "PendingWithIdentityViewController", bundle: nil) }()
    lazy var deniedViewController = { return UIViewController(nibName: "DeniedViewController", bundle: nil) }()
    
    lazy var pendingNeedsIdentityViewController: PendingNeedsIdentityViewController = {
      [unowned self] in
      return PendingNeedsIdentityViewController(delegate: self)
    }()
    
    lazy var approvedViewController: ApprovedViewController = {
      [unowned self] in
      return ApprovedViewController(delegate: self)
    }()
    
    init(delegate: PendingAccessDelegate, scopes: [API.Scopes], accessRequestId: String) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.accessDelegate = delegate
        self.scopes = scopes
        self.requestId = accessRequestId
    }
    
    init(delegate: PendingAccessDelegate, scopes: [API.Scopes], accessRequest: AccessRequest) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.accessDelegate = delegate
        self.scopes = scopes
        self.accessRequest = accessRequest
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        setViewControllers([updatingViewController], direction: .Forward, animated: false, completion: nil)
        if let digitsSession = Digits.sharedInstance().session() {
            // Already signed into Digits
            if let accessRequest = self.accessRequest {
                // We literally just created the access request
                if accessRequest.user.facebook != nil {
                    setViewControllers([pendingWithIdentityViewController], direction: .Forward, animated: true, completion: nil)
                } else {
                    setViewControllers([pendingNeedsIdentityViewController], direction: .Forward, animated: true, completion: nil)
                }
            } else {
                // Access request could be approved by now, let’s find out
                API.shared().getAuthToken(digitsSession, scopes: self.scopes) { accessToken in
                    do {
                        self.accessToken = try accessToken.value()
                        // Access Request must have been approved
                        API.shared().accessToken = self.accessToken!
                        self.setViewControllers([self.approvedViewController], direction: .Forward, animated: true, completion: nil)
                    } catch API.Error.Unauthorized {
                        self.getAccessRequest(digitsSession)
                    } catch let error as NSError {
                        self.accessDelegate.pendingAccessViewController(self, failedWith: error)
                    }
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
        accessDelegate.pendingAccessViewController(self, failedWith: error)
    }
    
    func signInViewController(viewController: SignInViewController, grantedKnownUser token: AccessToken) {
        accessToken = token
        setViewControllers([approvedViewController], direction: .Forward, animated: true, completion: nil)
    }
    
    func signInViewController(viewController: SignInViewController, grantedUnknownUser token: AccessToken) {
        // This is impossible
        accessDelegate.pendingAccessViewController(self, failedWith: NSError(domain: API.ERROR_DOMAIN, code: 3, userInfo: [
            "developerMessage": "PendingAccessViewController signed in but got an unknown user. Something is terribly wrong."
        ]))
    }
    
    func signInViewControllerCouldNotGrantToken(viewController viewController: SignInViewController) {
        // Access Request wasn’t approved; get status from server
        self.getAccessRequest(Digits.sharedInstance().session()!)
    }
    
    private func getAccessRequest(digitsSession: DGTSession) {
        API.shared().getAccessRequest(self.requestId, session: digitsSession) { accessRequest in
            do {
                self.accessRequest = try accessRequest.value()
                if (self.accessRequest!.status == .Rejected) {
                    self.setViewControllers([self.deniedViewController], direction: .Forward, animated: true, completion: nil)
                } else {
                    if (self.accessRequest!.status == .Approved) {
                        // TODO alert the authorities but carry on pretending it’s pending
                    }
                    
                    if (self.accessRequest!.user.facebook != nil) {
                        self.setViewControllers([self.pendingWithIdentityViewController], direction: .Forward, animated: true, completion: nil)
                    } else {
                        if let facebookToken = FBSDKAccessToken.currentAccessToken() {
                            self.updateAccessRequest(facebookToken)
                        } else {
                            self.setViewControllers([self.pendingNeedsIdentityViewController], direction: .Forward, animated: true, completion: nil)
                        }
                    }
                }
            } catch let error as NSError {
                self.accessDelegate.pendingAccessViewController(self, failedWith: error)
            }
        }
    }
    
    func pendingNeedsIdentity(viewController viewController: PendingNeedsIdentityViewController, received token: FBSDKAccessToken) {
        updateAccessRequest(token)
    }
    
    func approvedViewControllerTappedGetStarted(viewController viewController: ApprovedViewController) {
        accessDelegate.pendingAccessViewController(self, granted: accessToken!)
    }
    
    private func updateAccessRequest(token: FBSDKAccessToken) {
        API.shared().updateAccessRequest(self.accessRequest!, session: Digits.sharedInstance().session()!, facebookToken: token.tokenString) { accessRequest in
            do {
                self.accessRequest = try accessRequest.value()
                self.setViewControllers([self.pendingWithIdentityViewController], direction: .Forward, animated: true, completion: nil)
            } catch let error as NSError {
                self.accessDelegate.pendingAccessViewController(self, failedWith: error)
            }
        }
    }
}
