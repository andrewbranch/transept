//
//  CalendarSettingsViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 12/4/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

@objc protocol CalendarsDataSourceDelegate {
    var tableView: UITableView? { get set }
    optional func dataSourceDidStartLoadingAPI(dataSource: CalendarsDataSource) -> Void
    func dataSourceDidFinishLoadingAPI(dataSource: CalendarsDataSource) -> Void
    func dataSource(dataSource: CalendarsDataSource, failedToLoadWithError error: NSError?) -> Void
}

class CalendarSettingsViewController: UIViewController, UITableViewDelegate, CalendarsDataSourceDelegate, ErrorAlertable {
    
    @IBOutlet var tableView: UITableView?
    var dataSource: CalendarsDataSource?
    var delegate: CalendarSettingsDelegate?
    var selectButton: UIButton?
    
    lazy var tableViewController: UITableViewController = {
        return UITableViewController(style: self.tableView!.style)
    }()
    
    var errorAlertToBeShown: UIAlertView?
    var lastCalendarIds = NSUserDefaults.standardUserDefaults().objectForKey("selectedCalendarIds") as [String]?
    var currentCalendarIds: [String]? = NSUserDefaults.standardUserDefaults().objectForKey("selectedCalendarIds") as [String]? {
        didSet (oldValue) {
            NSUserDefaults.standardUserDefaults().setObject(self.currentCalendarIds!, forKey: "selectedCalendarIds")
            setButtonText()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewController.tableView = self.tableView!
        self.tableViewController.tableView.delegate = self
        self.tableView!.registerNib(UINib(nibName: "CalendarSettingsSelectTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "selectCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (self.currentCalendarIds == nil) {
            self.currentCalendarIds = self.dataSource!.calendars.map { $0.id }
        }
        self.tableView!.dataSource = self.dataSource!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let alert = self.errorAlertToBeShown {
            alert.show()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss() {
        self.delegate!.calendarSettingsController(self, didUpdateSelectionFrom: self.dataSource!.calendars.filter { find(self.lastCalendarIds!, $0.id) != nil }, to: self.dataSource!.calendars.filter { find(self.currentCalendarIds!, $0.id) != nil })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) { return }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? CalendarSettingsTableViewCell {
            cell.setSelected(true, animated: false)
        }
        self.currentCalendarIds!.append(self.dataSource!.calendarForIndexPath(indexPath)!.id)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) { return }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? CalendarSettingsTableViewCell {
            cell.setSelected(false, animated: false)
        }
        let index = find(self.currentCalendarIds!, self.dataSource!.calendarForIndexPath(indexPath)!.id)!
        self.currentCalendarIds!.removeAtIndex(index)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let calendar = self.dataSource!.calendarForIndexPath(indexPath) {
            if (self.currentCalendarIds!.contains(calendar.id)) {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
            }
        } else if (indexPath.row == 0) {
            if (self.selectButton == nil) {
                self.selectButton = (cell as CalendarSettingsSelectTableViewCell).selectButton
                self.selectButton!.addTarget(self, action: "toggleSelection:", forControlEvents: UIControlEvents.TouchUpInside)
                setButtonText()
            }
        }
    }
    
    func toggleSelection(sender: UIButton!) {
        // Select all
        if (self.currentCalendarIds!.count < self.dataSource!.calendars.count) {
            for id in self.dataSource!.calendars.map({ $0.id }) - self.currentCalendarIds! {
                let indexPath = self.dataSource!.indexPathForCalendarId(id)!
                self.tableView!.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
                self.tableView(self.tableView!, didSelectRowAtIndexPath: indexPath)
            }
        // Select none
        } else {
            for id in self.currentCalendarIds! {
                let indexPath = self.dataSource!.indexPathForCalendarId(id)!
                self.tableView!.deselectRowAtIndexPath(indexPath, animated: false)
                self.tableView(self.tableView!, didDeselectRowAtIndexPath: indexPath)
            }
        }
    }
    
    func dataSourceDidFinishLoadingAPI(dataSource: CalendarsDataSource) {
        self.tableView?.reloadData()
    }
    
    func dataSource(dataSource: CalendarsDataSource, failedToLoadWithError error: NSError?) {
        ErrorAlerter.showLoadingAlertInViewController(self)
    }
    
    func setButtonText() {
        if let button = self.selectButton {
            UIView.setAnimationsEnabled(false)
            if (self.currentCalendarIds!.count == self.dataSource!.calendars.count) {
                button.setTitle("Select none", forState: UIControlState.Normal)
            } else {
                button.setTitle("Select all", forState: UIControlState.Normal)
            }
            UIView.setAnimationsEnabled(true)
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
