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
    
}

class DirectoryTableViewController: CustomTableViewController, DirectoryDataSourceDelegate {
    
    var dataSource: DirectoryDataSource?
    @IBOutlet var signInOverlay: UIView?
    @IBOutlet var signInButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.dataSource!.title as String
        self.tableView!.dataSource = self.dataSource!
        
        if (API.shared().hasAccessToken) {
            signInOverlay!.hidden = true
        }
    }
    
    @IBAction func didTapSignInButton() {
        Digits.sharedInstance().authenticateWithCompletion { session, error in
            guard error == nil else {
                ErrorAlerter.showUnknownErrorMessageInViewController(self, withOriginalError: error!)
                return
            }
            
            do {
                try API.shared().getAuthToken(session, scopes: [.DirectoryFullReadAccess]) { token in
                    do {
                        let token = try token.value()
                        API.shared().accessToken = token
                        
                        // Logged in and has permission to read directory.
                        if (token.needsVerification) {
                            // New user, should confirm that identity is correct
                        } else {
                            // Known user, just hide the gate
                            self.signInOverlay!.hidden = true
                            self.dataSource!.refresh()
                        }
                    } catch API.Error.Unauthorized {
                        // Could not grant requested scopes; start access request
                        do {
                            try API.shared().requestAccess([.DirectoryFullReadAccess]) { accessRequest in
                                // Created access request.
                                // Prompt to prove identity with Facebook or Twitter, or instruct to go to front office.
                                
                                // Indicate that an access request is open.
                                // applicationDidBecomeActive should check this and review the status of the request.
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "accessRequestOpen")
                            }
                        } catch let error as NSError {
                            // Failed to create access request
                            ErrorAlerter.showUserErrorMessage(error, inViewController: self)
                        }
                    } catch let error as NSError {
                        ErrorAlerter.showUserErrorMessage(error, inViewController: self)
                    }
                }
            } catch let error as NSError {
                ErrorAlerter.showUserErrorMessage(error, inViewController: self)
            }
        }
    }
}
