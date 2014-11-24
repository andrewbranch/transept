//
//  PrayerRequestViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/17/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class PrayerRequestViewController: UIViewController, UITextViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet var textView: UIPlaceHolderTextView?
    @IBOutlet var label: UILabel?
    @IBOutlet var button: UIButton?
    @IBOutlet var scrollView: UIScrollView?
    private var successAlert: UIAlertView?
    private var errorAlert: UIAlertView?
    private let url = NSURL(string: "https://fumc.herokuapp.com/api/emailer/send")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.label!.font = UIFont.fumcMainFontRegular14
        
        var toolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        toolbar.barStyle = UIBarStyle.Default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target:nil, action:nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard"),
        ]
        (toolbar.items![1] as UIBarButtonItem).setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFontOfSize(16),
            NSForegroundColorAttributeName: UIColor.fumcRedColor()
        ], forState: UIControlState.Normal)
        
        toolbar.sizeToFit()
        self.textView!.inputAccessoryView = toolbar
        self.textView!.delegate = self
        self.textView!.placeholder = "Tap to begin editing..."
        
        self.successAlert = UIAlertView(title: "Submitted", message: "Your prayer has been submitted to our prayer team. May the peace of God be with you.", delegate: self, cancelButtonTitle: "OK")
        self.errorAlert = UIAlertView(title: "Error Submitting", message: "We’re having trouble processing your request right now. Do you want to copy your request into a new email message?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Copy to Email")
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            let keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height - self.navigationController!.navigationBar.frame.height, 0.0)
            self.scrollView!.contentInset = contentInsets
            self.scrollView!.scrollIndicatorInsets = contentInsets
            // Using the setContentOffset:animated: method doesn't animate the first time for some reason
            UIView.animateWithDuration(0.25) {
                self.scrollView!.contentOffset = CGPointMake(0.0, self.textView!.frame.origin.y - 20)
            }
        }
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.scrollView!.contentInset = UIEdgeInsetsZero
            self.scrollView!.scrollIndicatorInsets = UIEdgeInsetsZero
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.textView!.resignFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text.isEmpty) {
            self.button!.enabled = false
        } else {
            self.button!.enabled = true
        }
    }
    
    @IBAction func sendRequest(sender: AnyObject?) {
        let request = NSMutableURLRequest(URL: self.url!)
        let data = "{\"email\": \"\(self.textView!.text)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        request.HTTPBody = data!
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data!.length)", forHTTPHeaderField: "Content-Length")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil || (response as NSHTTPURLResponse).statusCode != 200) {
                self.errorAlert!.show()
            } else {
                self.successAlert!.show()
            }
        }
    }
    
    
    // MARK: - Alert View Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView === self.errorAlert! && buttonIndex == 1) {
            let emailURL = NSURL(string: "mailto:fumc@pensacolafirstchurch.com?subject=Prayer Request&body=\(self.textView!.text)".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            if let url = emailURL {
                UIApplication.sharedApplication().openURL(url)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:fumc@pensacolafirstchurch.com")!)
            }
        } else if (alertView === self.successAlert!) {
            self.textView!.text = ""
            dismissKeyboard()
            self.navigationController!.popViewControllerAnimated(true)
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
