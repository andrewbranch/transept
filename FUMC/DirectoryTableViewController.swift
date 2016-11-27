//
//  DirectoryTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 5/26/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import DigitsKit

public protocol DirectoryDataSourceDelegate {
    func dataSource(_ dataSource: DirectoryDataSource, failedToLoadWith error: API.Error)
}

class DirectoryTableViewController: CustomTableViewController, DirectoryDataSourceDelegate, AuthenticationDelegate, SignInDelegate, PendingAccessDelegate {
    
    let requiredScopes = [API.Scopes.DirectoryFullReadAccess]
    let accessRequestKey = "directoryAccessRequestId"
    var dataSource: DirectoryDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title as String
        self.tableView!.dataSource = self.dataSource!
        
        if let requestId = UserDefaults.standard.value(forKey: accessRequestKey) as? String {
            // Access Request is open; show pending screen
            launchPendingAccessFlow(requestId)
        } else if !API.shared().hasAccessToken || (API.shared().accessToken!.expires as Date) < Date() {
            self.launchAuthFlow(token: nil, forceRefresh: true)
        }
    }
    
    fileprivate func launchAuthFlow(token: AccessToken?, forceRefresh: Bool = false) {
        if Digits.sharedInstance().session() == nil || forceRefresh {
            let signInController = SignInViewController(delegate: self, requestScopes: requiredScopes)
            addChildViewController(signInController)
            signInController.view.frame = view.bounds
            view.addSubview(signInController.view)
            signInController.didMove(toParentViewController: self)
        } else {
            let authenticationViewController = AuthenticationViewController(delegate: self, requestScopes: requiredScopes, token: token)
            DispatchQueue.main.async {
                self.present(authenticationViewController, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func launchPendingAccessFlow(_ requestId: String) {
        launchPendingAccessFlow(
            PendingAccessViewController(delegate: self, scopes: requiredScopes, accessRequestId: requestId)
        )
        
    }
    
    fileprivate func launchPendingAccessFlow(_ request: AccessRequest) {
        launchPendingAccessFlow(
            PendingAccessViewController(delegate: self, scopes: requiredScopes, accessRequest: request)
        )
    }
    
    fileprivate func launchPendingAccessFlow(_ pendingAccessViewController: PendingAccessViewController) {
        self.addChildViewController(pendingAccessViewController)
        pendingAccessViewController.view.frame = self.view.bounds
        self.view.addSubview(pendingAccessViewController.view)
        pendingAccessViewController.didMove(toParentViewController: self)
    }
    
    func dataSource(_ dataSource: DirectoryDataSource, failedToLoadWith error: API.Error) {
        switch error {
        case .unauthenticated: // this should never happen
            launchAuthFlow(token: nil, forceRefresh: true)
            break;
        case .unauthorized:
            launchAuthFlow(token: nil, forceRefresh: true)
            break;
        default:
            ErrorAlerter.showUnknownErrorMessageInViewController(self, withOriginalError: nil)
        }
    }
    
    func authenticationViewController(_ viewController: AuthenticationViewController, failedWith error: API.Error) {
        DispatchQueue.main.async {
            viewController.dismiss(animated: true) {
                ErrorAlerter.showUserErrorMessage(error, inViewController: self)
            }
        }
    }
    
    func authenticationViewController(_ viewController: AuthenticationViewController, granted accessToken: AccessToken) {
        dataSource!.refresh()
        DispatchQueue.main.async {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func authenticationViewController(_ viewController: AuthenticationViewController, opened accessRequest: AccessRequest) {
        viewController.dismiss(animated: true, completion: nil)
        // Indicate that an access request is open.
        // applicationDidBecomeActive should check this and review the status of the request.
        UserDefaults.standard.setValue(accessRequest.id, forKey: accessRequestKey)
        launchPendingAccessFlow(accessRequest)
    }
    
    func pendingAccessViewController(_ viewController: PendingAccessViewController, granted accessToken: AccessToken) {
        dataSource!.refresh()
        UserDefaults.standard.setValue(nil, forKey: self.accessRequestKey)
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    func pendingAccessViewController(_ viewController: PendingAccessViewController, failedWith error: NSError) {
        ErrorAlerter.showUserErrorMessage(error, inViewController: self)
    }
    
    func signInViewController(_ viewController: SignInViewController, failedWith error: NSError) {
        ErrorAlerter.showUserErrorMessage(error, inViewController: self)
    }
    
    func signInViewControllerCouldNotGrantToken(viewController: SignInViewController) {
        launchAuthFlow(token: nil)
    }
    
    func signInViewController(_ viewController: SignInViewController, grantedKnownUser token: AccessToken) {
        dataSource!.refresh()
        DispatchQueue.main.async {
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func signInViewController(_ viewController: SignInViewController, grantedUnknownUser token: AccessToken) {
        launchAuthFlow(token: token)
    }
}
