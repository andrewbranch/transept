//
//  CustomTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CustomTableViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    let activityView = UIView(frame: CGRectMake(0, 0, 100, 100))
    let refreshControl = UIRefreshControl()
    
    private var showWhenLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 30, 30))
        self.activityView.backgroundColor = UIColor(white: 0, alpha: 0.75)
        self.activityView.layer.cornerRadius = 10
        self.activityView.addSubview(activityIndicator)
        activityIndicator.center = self.activityView.center
        activityIndicator.startAnimating()
        self.activityView.center = self.view.center
        self.activityView.frame = CGRectMake(self.activityView.frame.minX, self.activityView.frame.minY - 80, self.activityView.frame.width, self.activityView.frame.height)
        
        self.refreshControl.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(self.refreshControl)
        
        if (self.showWhenLoaded) {
            showLoadingView()
            self.showWhenLoaded = false
        }
    }
    
    func showLoadingView() {
        if (isViewLoaded()) {
            self.view.insertSubview(self.activityView, aboveSubview: self.tableView!)
        } else {
            self.showWhenLoaded = true
        }
    }
    
    func hideLoadingView() {
        if (isViewLoaded()) {
            self.activityView.removeFromSuperview()
        } else {
            self.showWhenLoaded = false
        }
    }
    
    func reloadData() {
        self.refreshControl.endRefreshing()
    }

}
