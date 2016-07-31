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

class DirectoryTableViewController: CustomTableViewController, DirectoryDataSourceDelegate, AuthenticationDelegate {
    
    var dataSource: DirectoryDataSource?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title as String
        self.tableView!.dataSource = self.dataSource!
        
        if (!API.shared().hasAccessToken) {
            launchAuthFlow()
        }
    }
    
    func launchAuthFlow() {
        let authenticationViewController = AuthenticationViewController(nibName: "AuthenticationViewController", bundle: nil)
        authenticationViewController.requestScopes = [API.Scopes.DirectoryFullReadAccess]
        authenticationViewController.delegate = self
        self.presentViewController(authenticationViewController, animated: true, completion: nil)
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
        ErrorAlerter.showUserErrorMessage(error, inViewController: self)
    }
    
    func authenticationViewController(viewController: AuthenticationViewController, granted accessToken: AccessToken) {
        NSLog("granted access token")
    }
    
    func authenticationViewController(viewController: AuthenticationViewController, opened accessRequest: AccessRequest) {
        NSLog("opened access request")
    }
}
