//
//  CustomTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

open class CustomTableViewController: UIViewController, ErrorAlertable {
    
    @IBOutlet var tableView: UITableView?
    var errorAlertToBeShown: UIAlertView?
    let activityView = ActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let refreshControl = UIRefreshControl()
    lazy var tableViewController: UITableViewController = {
       return UITableViewController(style: self.tableView!.style)
    }()
    
    fileprivate var showWhenLoaded = false
    fileprivate lazy var backgroundView: UILabel = {
        var backgroundLabel = UILabel(frame: self.tableView!.frame)
        backgroundLabel.textAlignment = NSTextAlignment.center
        backgroundLabel.font = UIFont.fumcMainFontRegular26
        backgroundLabel.textColor = UIColor.lightGray
        backgroundLabel.text = "Nothing to display"
        backgroundLabel.isHidden = true
        return backgroundLabel
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 80)
        
        self.tableViewController.tableView = self.tableView!
        self.tableViewController.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(CustomTableViewController.reloadData), for: UIControlEvents.valueChanged)
        
        self.tableView!.backgroundView = self.backgroundView
        
        if (self.showWhenLoaded) {
            showLoadingView()
            self.showWhenLoaded = false
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let alert = self.errorAlertToBeShown {
            alert.show()
            self.errorAlertToBeShown = nil
        }
    }
    
    func showLoadingView() {
        if (isViewLoaded) {
            self.view.insertSubview(self.activityView, aboveSubview: self.tableView!)
        } else {
            self.showWhenLoaded = true
        }
    }
    
    func hideLoadingView() {
        if (isViewLoaded) {
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
