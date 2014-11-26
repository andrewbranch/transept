//
//  MediaWebViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/30/14.
//  Copyright (c) statusBarHeight14 FUMC Pensacola. All rights reserved.
//

import UIKit

class MediaWebViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var webView: UIWebView?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    private var previousScrollViewYOffset = CGFloat(0)
    
    var url: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView!.delegate = self
        self.webView!.scrollView.delegate = self
        self.webView!.hidden = true
        self.webView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.webView!.scalesPageToFit = true
        
        if let url = self.url {
            var request = NSURLRequest(URL: url)
            self.webView!.loadRequest(request)
        } else {
            ErrorAlerter.loadingAlertBasedOnReachability().show()
        }
    }
    
    // MARK: - Web View Delegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityIndicator!.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator!.stopAnimating()
        self.webView!.hidden = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        ErrorAlerter.loadingAlertBasedOnReachability().show()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (navigationType == UIWebViewNavigationType.LinkClicked) {
            UIApplication.sharedApplication().openURL(request.URL)
            return false
        }
        
        return true
    }
    
    // MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var frame = self.navigationController!.navigationBar.frame
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let size = frame.size.height - statusBarHeight;
        let framePercentageHidden = ((statusBarHeight - frame.origin.y) / (frame.size.height - 1))
        let scrollOffset = scrollView.contentOffset.y
        let scrollDiff = scrollOffset - self.previousScrollViewYOffset
        let scrollHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            frame.origin.y = statusBarHeight
        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            frame.origin.y = -size
        } else {
            frame.origin.y = min(statusBarHeight, max(-size, frame.origin.y - 4 * (frame.size.height * (scrollDiff / scrollHeight))))
        }
        
        self.navigationController!.navigationBar.frame = frame
        self.view.frame = CGRectMake(0, frame.maxY, self.view.frame.width, self.view.frame.height + self.view.frame.origin.y - frame.maxY)
        
        self.updateBarButtonItems(alpha: 1 - framePercentageHidden)
        self.previousScrollViewYOffset = scrollOffset
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            stoppedScrolling()
        }
    }
    
    func stoppedScrolling() {
        let frame = self.navigationController!.navigationBar.frame
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        
        // Stopped in between
        if (frame.origin.y < statusBarHeight && frame.origin.y > statusBarHeight - frame.height) {
            animateNavBarTo(statusBarHeight)
        }
    }
    
    func updateBarButtonItems(#alpha: CGFloat) {
        self.navigationItem.backBarButtonItem?.tintColor = self.navigationItem.backBarButtonItem?.tintColor.colorWithAlphaComponent(alpha)
        self.navigationItem.titleView?.alpha = alpha
        self.navigationController!.navigationBar.tintColor = self.navigationController!.navigationBar.tintColor.colorWithAlphaComponent(alpha)
    }
    
    func animateNavBarTo(y: CGFloat) {
        UIView.animateWithDuration(0.2) {
            var frame = self.navigationController!.navigationBar.frame
            let alpha = frame.origin.y >= y ? 0 : 1
            frame.origin.y = y
            self.navigationController!.navigationBar.frame = frame
            self.updateBarButtonItems(alpha: CGFloat(alpha))
        }
    }

}
