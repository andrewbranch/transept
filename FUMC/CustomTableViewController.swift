//
//  CustomTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

class CustomTableViewController: UIViewController, ErrorAlertable {
    
    @IBOutlet var tableView: UITableView?
    var errorAlertToBeShown: UIAlertView?
    let activityView = ActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
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
        
        self.activityView.center = CGPointMake(self.view.center.x, self.view.center.y - 80)
        
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
        // to be overridden
        self.refreshControl.endRefreshing()
    }

}
