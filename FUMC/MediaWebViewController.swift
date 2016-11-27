    //
//  MediaWebViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/30/14.
//  Copyright (c) statusBarHeight14 FUMC Pensacola. All rights reserved.
//

import UIKit
import Crashlytics

class MediaWebViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var webView: UIWebView?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    fileprivate var previousScrollViewYOffset = CGFloat(0)
    fileprivate var navController: UINavigationController?
    
    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView!.delegate = self
        self.webView!.scrollView.delegate = self
        self.webView!.isHidden = true
        self.webView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.webView!.scalesPageToFit = true
        
        if let url = self.url {
            let request = URLRequest(url: url)
            self.webView!.loadRequest(request)
        } else {
            ErrorAlerter.loadingAlertBasedOnReachability().show()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navController = self.navigationController
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.navController!.navigationBar.frame.origin.y < 0) {
            animateNavBarTo(UIApplication.shared.statusBarFrame.height)
        }
    }
    
    // MARK: - Web View Delegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator!.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator!.stopAnimating()
        self.webView!.isHidden = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if (self.isViewLoaded && self.view.window != nil) {
            ErrorAlerter.loadingAlertBasedOnReachability().show()
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (navigationType == UIWebViewNavigationType.linkClicked) {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        
        return true
    }
    
    // MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navigationController = self.navigationController {
            var frame = navigationController.navigationBar.frame
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
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
            
            navigationController.navigationBar.frame = frame
            self.view.frame = CGRect(x: 0, y: frame.maxY, width: self.view.frame.width, height: self.view.frame.height + self.view.frame.origin.y - frame.maxY)
            
            self.updateBarButtonItems(alpha: 1 - framePercentageHidden)
            self.previousScrollViewYOffset = scrollOffset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            stoppedScrolling()
        }
    }
    
    func stoppedScrolling() {
        if let navigationController = self.navigationController {
            let frame = navigationController.navigationBar.frame
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            
            // Stopped in between
            if (frame.origin.y < statusBarHeight && frame.origin.y > statusBarHeight - frame.height) {
                animateNavBarTo(statusBarHeight)
            }
        }
    }
    
    func updateBarButtonItems(alpha: CGFloat) {
        self.navigationItem.backBarButtonItem?.tintColor = self.navigationItem.backBarButtonItem?.tintColor!.withAlphaComponent(alpha)
        self.navigationItem.titleView?.alpha = alpha
        self.navController!.navigationBar.tintColor = self.navController!.navigationBar.tintColor.withAlphaComponent(alpha)
    }
    
    func animateNavBarTo(_ y: CGFloat) {
        if let navigationController = self.navController {
            UIView.animate(withDuration: 0.2, animations: {
                var frame = navigationController.navigationBar.frame
                let alpha = frame.origin.y >= y ? 0 : 1
                frame.origin.y = y
                navigationController.navigationBar.frame = frame
                self.updateBarButtonItems(alpha: CGFloat(alpha))
            }) 
        }
    }

}
