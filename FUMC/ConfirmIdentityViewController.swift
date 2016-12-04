//
//  ConfirmIdentityViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 7/31/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

protocol ConfirmDelegate {
    func confirmViewControllerConfirmedIdentity(viewController: ConfirmIdentityViewController)
    func confirmViewControllerDeniedIdentity(viewController: ConfirmIdentityViewController)
}

class ConfirmIdentityViewController: UIViewController {

    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var denyButton: UIButton!
    @IBOutlet var greetingLabel: UILabel!
    
    var delegate: ConfirmDelegate!
    var firstName: String!
    var lastName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        greetingLabel.text = "Hello, \(firstName!)!"
        denyButton.setTitle("I’m not \(firstName!) \(lastName!)", for: UIControlState())
    }
    
    @IBAction func tappedConfirmButton() {
        delegate.confirmViewControllerConfirmedIdentity(viewController: self)
    }
    
    @IBAction func tappedDenyButton() {
        delegate.confirmViewControllerDeniedIdentity(viewController: self)
    }

}
