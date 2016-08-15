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
    func dataSource(dataSource: DirectoryDataSource, failedToLoadWith error: API.Error)
}

class DirectoryTableViewController: CustomTableViewController, DirectoryDataSourceDelegate, AuthenticationDelegate, PendingAccessDelegate {
    
    let requiredScopes = [API.Scopes.DirectoryFullReadAccess]
    let accessRequestKey = "directoryAccessRequestId"
    var dataSource: DirectoryDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title as String
        self.tableView!.dataSource = self.dataSource!
        
        if let requestId = NSUserDefaults.standardUserDefaults().valueForKey(accessRequestKey) as? String {
            // Access Request is open; show pending screen
            launchPendingAccessFlow(requestId)
        } else if (!API.shared().hasAccessToken) {
            launchAuthFlow()
        }
    }
    
    private func launchAuthFlow() {
        let authenticationViewController = AuthenticationViewController(requestScopes: requiredScopes, delegate: self)
        self.presentViewController(authenticationViewController, animated: true, completion: nil)
    }
    
    private func launchPendingAccessFlow(requestId: String) {
        launchPendingAccessFlow(
            PendingAccessViewController(delegate: self, scopes: requiredScopes, accessRequestId: requestId)
        )
        
    }
    
    private func launchPendingAccessFlow(request: AccessRequest) {
        launchPendingAccessFlow(
            PendingAccessViewController(delegate: self, scopes: requiredScopes, accessRequest: request)
        )
    }
    
    private func launchPendingAccessFlow(pendingAccessViewController: PendingAccessViewController) {
        self.addChildViewController(pendingAccessViewController)
        pendingAccessViewController.view.frame = self.view.frame
        self.view.addSubview(pendingAccessViewController.view)
        pendingAccessViewController.didMoveToParentViewController(self)
    }
    
    func dataSource(dataSource: DirectoryDataSource, failedToLoadWith error: API.Error) {
        switch error {
        case .Unauthenticated: // this should never happen
            launchAuthFlow()
            break;
        case .Unauthorized:
            launchAuthFlow()
            break;
        default:
            ErrorAlerter.showUnknownErrorMessageInViewController(self, withOriginalError: nil)
        }
    }
    
    func authenticationViewController(viewController: AuthenticationViewController, failedWith error: API.Error) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        ErrorAlerter.showUserErrorMessage(error, inViewController: self)
    }
    
    func authenticationViewController(viewController: AuthenticationViewController, granted accessToken: AccessToken) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        dataSource!.refresh()
    }
    
    func authenticationViewController(viewController: AuthenticationViewController, opened accessRequest: AccessRequest) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
        // Indicate that an access request is open.
        // applicationDidBecomeActive should check this and review the status of the request.
        NSUserDefaults.standardUserDefaults().setValue(accessRequest.id, forKey: accessRequestKey)
        launchPendingAccessFlow(accessRequest)
    }
    
    func pendingAccessViewController(viewController: PendingAccessViewController, granted accessToken: AccessToken) {
        dataSource!.refresh()
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: self.accessRequestKey)
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    func pendingAccessViewController(viewController: PendingAccessViewController, failedWith error: NSError) {
        ErrorAlerter.showUserErrorMessage(error, inViewController: self)
    }
}
