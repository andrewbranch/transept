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
            API.shared().getAuthToken(session, scopes: [.DirectoryFullReadAccess]) { token in
                do {
                    let token = try token.value()
                    API.shared().accessToken = token
                    guard token.scopes.contains(.DirectoryFullReadAccess) else {
                        API.shared().requestAccess([.DirectoryFullReadAccess]) { accessRequest in
                            
                        }
                        
                        return
                    }
                    
                    self.signInOverlay!.hidden = true
                } catch {
                    
                }
            }
        }
    }
}
