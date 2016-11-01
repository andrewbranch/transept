//
//  ApprovedViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 10/31/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

protocol ApprovedDelegate {
    func approvedViewControllerTappedGetStarted(viewController viewController: ApprovedViewController)
}

class ApprovedViewController: UIViewController {
    var delegate: ApprovedDelegate!
    
    init(delegate: ApprovedDelegate) {
        super.init(nibName: "ApprovedViewController", bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func tappedGetStarted() {
        delegate.approvedViewControllerTappedGetStarted(viewController: self)
    }

}
