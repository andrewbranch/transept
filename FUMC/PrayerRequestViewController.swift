//
//  PrayerRequestViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/17/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import Crashlytics

class PrayerRequestViewController: UIViewController, UITextViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet var textView: UIPlaceHolderTextView?
    @IBOutlet var label: UILabel?
    @IBOutlet var button: UIButton?
    @IBOutlet var scrollView: UIScrollView?
    fileprivate var successAlert: UIAlertView?
    fileprivate var errorAlert: UIAlertView?
    fileprivate let activityView = ActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.label!.font = UIFont.fumcMainFontRegular14
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target:nil, action:nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(PrayerRequestViewController.dismissKeyboard)),
        ]
        (toolbar.items![1] as UIBarButtonItem).setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.fumcRedColor()
        ], for: UIControlState())
        
        toolbar.sizeToFit()
        self.textView!.inputAccessoryView = toolbar
        self.textView!.delegate = self
        self.textView!.placeholder = "Tap to begin editing..."
        
        self.successAlert = UIAlertView(title: "Submitted", message: "Your prayer has been submitted to our prayer team. May the peace of God be with you.", delegate: self, cancelButtonTitle: "OK")
        self.errorAlert = UIAlertView(title: "Error Submitting", message: "We’re having trouble processing your request right now. Do you want to copy your request into a new email message?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Copy to Email")
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { (notification) -> Void in
            let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height - self.navigationController!.navigationBar.frame.height, 0.0)
            self.scrollView!.contentInset = contentInsets
            self.scrollView!.scrollIndicatorInsets = contentInsets
            // Using the setContentOffset:animated: method doesn't animate the first time for some reason
            UIView.animate(withDuration: 0.25, animations: {
                self.scrollView!.contentOffset = CGPoint(x: 0.0, y: self.textView!.frame.origin.y - 20)
            }) 
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.scrollView!.contentInset = UIEdgeInsets.zero
            self.scrollView!.scrollIndicatorInsets = UIEdgeInsets.zero
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEvent(withName: "Viewed prayer request scene", customAttributes: nil)
        #endif
    }
    
    func dismissKeyboard() {
        self.textView!.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.text.isEmpty) {
            self.button!.isEnabled = false
        } else {
            self.button!.isEnabled = true
        }
    }
    
    func beginLoading() {
        self.textView!.backgroundColor = UIColor.lightGray
        self.button!.isEnabled = false
        self.activityView.center = CGPoint(x: self.view.center.x, y: self.textView!.center.y)
        self.scrollView!.addSubview(self.activityView)
    }
    
    func endLoading() {
        self.textView!.backgroundColor = UIColor.white
        self.button!.isEnabled = true
        self.activityView.removeFromSuperview()
    }
    
    @IBAction func sendRequest(_ sender: AnyObject?) {
        self.dismissKeyboard()
        self.beginLoading()
        API.shared().sendPrayerRequest(self.textView!.text) { error in
            self.endLoading()
            if (error != nil) {
                self.errorAlert!.show()
            } else {
                self.successAlert!.show()
            }
        }
    }
    
    
    // MARK: - Alert View Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (alertView === self.errorAlert! && buttonIndex == 1) {
            let emailURL = URL(string: "mailto:fumc@pensacolafirstchurch.com?subject=Prayer Request&body=\(self.textView!.text)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            if let url = emailURL {
                UIApplication.shared.openURL(url)
            } else {
                UIApplication.shared.openURL(URL(string: "mailto:fumc@pensacolafirstchurch.com")!)
            }
        } else if (alertView === self.successAlert!) {
            self.textView!.text = ""
            dismissKeyboard()
            self.navigationController!.popViewController(animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
