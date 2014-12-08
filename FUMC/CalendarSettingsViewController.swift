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
}

class CalendarSettingsViewController: UIViewController, UITableViewDelegate, CalendarsDataSourceDelegate {
    
    @IBOutlet var tableView: UITableView?
    var dataSource: CalendarsDataSource?
    var delegate: CalendarSettingsDelegate?
    
    lazy var tableViewController: UITableViewController = {
        return UITableViewController(style: self.tableView!.style)
    }()
    
    var lastCalendarIds = NSUserDefaults.standardUserDefaults().objectForKey("selectedCalendarIds") as [String]?
    var currentCalendarIds: [String]? = NSUserDefaults.standardUserDefaults().objectForKey("selectedCalendarIds") as [String]? {
        didSet (oldValue) {
            NSUserDefaults.standardUserDefaults().setObject(self.currentCalendarIds!, forKey: "selectedCalendarIds")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewController.tableView = self.tableView!
        self.tableViewController.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView!.dataSource = self.dataSource!
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
        let cell = tableView.cellForRowAtIndexPath(indexPath) as CalendarSettingsTableViewCell
        self.currentCalendarIds!.append(self.dataSource!.calendarForIndexPath(indexPath)!.id)
        cell.setSelected(true, animated: false)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as CalendarSettingsTableViewCell
        let index = find(self.currentCalendarIds!, self.dataSource!.calendarForIndexPath(indexPath)!.id)!
        self.currentCalendarIds!.removeAtIndex(index)
        cell.setSelected(false, animated: false)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (find(self.currentCalendarIds!, self.dataSource!.calendarForIndexPath(indexPath)!.id) != nil) {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    func dataSourceDidFinishLoadingAPI(dataSource: CalendarsDataSource) {
        self.tableView?.reloadData()
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
