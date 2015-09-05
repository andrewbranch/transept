//
//  ErrorAlerter.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/25/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

@objc protocol ErrorAlertable {
    func isViewLoaded() -> Bool
    var view: UIView! { get set }
    var errorAlertToBeShown: UIAlertView? { get set }
}

class ErrorAlerter: NSObject {
    
    class func loadingAlertBasedOnReachability() -> UIAlertView {
        
        struct Static {
            static let internetNeededAlert = UIAlertView(title: "Internet Connection Needed", message: "An Internet connection is required to load this content.", delegate: nil, cancelButtonTitle: "Close")
            static let genericLoadingErrorAlert = UIAlertView(title: "Error Loading Content", message: "We’re having trouble loading the content on our end. Please check back later.", delegate: nil, cancelButtonTitle: "Close")
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
        if (appDelegate.internetReachability.currentReachabilityStatus() == .NotReachable) {
            return Static.internetNeededAlert
        }
        return Static.genericLoadingErrorAlert

    }
    
    class func showLoadingAlertInViewController(let viewController: ErrorAlertable) {
        if (viewController.isViewLoaded() && viewController.view.window != nil) {
            ErrorAlerter.loadingAlertBasedOnReachability().show()
        } else {
            viewController.errorAlertToBeShown = self.loadingAlertBasedOnReachability()
        }
    }
    
}
