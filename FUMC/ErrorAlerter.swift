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
    
    static let ERROR_DOMAIN = "com.fumcpensacola.transept"
    
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
    
    private class func alertWithUserErrorMessage(message: String?) -> UIAlertView {
        return UIAlertView(
            title: "Oh dear.",
            message: message ?? AppDelegate.USER_UNKNOWN_ERROR_MESSAGE,
            delegate: nil,
            cancelButtonTitle: "Close"
        )
    }
    
    class func alertWithUserErrorMessage(error: NSError) -> UIAlertView {
        return self.alertWithUserErrorMessage(error.userInfo["userMessage"] as! String?)
    }
    
    class func alertWithUserErrorMessage(error: API.Error) -> UIAlertView {
        switch error {
        case .Unknown(let userMessage, _, _):
            return self.alertWithUserErrorMessage(userMessage)
        default:
            return self.alertWithUserErrorMessage(nil)
        }
    }
    
    class func showUnknownErrorMessageInViewController(let viewController: ErrorAlertable, withOriginalError error: NSError?) {
        let unknownErrorAlert = self.alertWithUserErrorMessage(NSError(
            domain: self.ERROR_DOMAIN,
            code: 0,
            userInfo: ["userMessage": AppDelegate.USER_UNKNOWN_ERROR_MESSAGE]
        ))
        
        if (viewController.isViewLoaded()) {
            unknownErrorAlert.show()
        } else {
            viewController.errorAlertToBeShown = unknownErrorAlert
        }
        
        // TODO log original error
    }
    
    class func showUserErrorMessage(error: NSError, let inViewController viewController: ErrorAlertable) {
        if (viewController.isViewLoaded() && viewController.view.window != nil) {
            self.alertWithUserErrorMessage(error).show()
        } else {
            viewController.errorAlertToBeShown = self.alertWithUserErrorMessage(error)
        }
    }
    
    class func showUserErrorMessage(error: API.Error, let inViewController viewController: ErrorAlertable) {
        if (viewController.isViewLoaded() && viewController.view.window != nil) {
            self.alertWithUserErrorMessage(error).show()
        } else {
            viewController.errorAlertToBeShown = self.alertWithUserErrorMessage(error)
        }
    }
    
    class func showLoadingAlertInViewController(let viewController: ErrorAlertable) {
        if (viewController.isViewLoaded() && viewController.view.window != nil) {
            self.loadingAlertBasedOnReachability().show()
        } else {
            viewController.errorAlertToBeShown = self.loadingAlertBasedOnReachability()
        }
    }
    
}
