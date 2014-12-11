//
//  CustomTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CustomTableViewController: UIViewController, ErrorAlertable {
    
    @IBOutlet var tableView: UITableView?
    var errorAlertToBeShown: UIAlertView?
    let activityView = UIView(frame: CGRectMake(0, 0, 100, 100))
    let refreshControl = UIRefreshControl()
    lazy var tableViewController: UITableViewController = {
       return UITableViewController(style: self.tableView!.style)
    }()
    
    private var showWhenLoaded = false
    private lazy var backgroundView: UILabel = {
        var backgroundLabel = UILabel(frame: self.tableView!.frame)
        backgroundLabel.textAlignment = NSTextAlignment.Center
        backgroundLabel.font = UIFont.fumcMainFontRegular26
        backgroundLabel.textColor = UIColor.lightGrayColor()
        backgroundLabel.text = "Nothing to display"
        backgroundLabel.hidden = true
        return backgroundLabel
    }()

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
        
        self.tableViewController.tableView = self.tableView!
        self.tableViewController.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: "reloadData", forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView!.backgroundView = self.backgroundView
        
        if (self.showWhenLoaded) {
            showLoadingView()
            self.showWhenLoaded = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let alert = self.errorAlertToBeShown {
            alert.show()
            self.errorAlertToBeShown = nil
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
