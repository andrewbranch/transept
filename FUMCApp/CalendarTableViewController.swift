//
//  CalendarTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/10/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CalendarTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HomeViewPage {
    
    var pageViewController: HomeViewController?
    var events: Dictionary<NSString, [CalendarEvent]> = Dictionary<NSString, [CalendarEvent]>()
    var sortedKeys = [NSString]()
    let dateFormatter = NSDateFormatter()
    @IBOutlet var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView!.registerNib(UINib(nibName: "CalendarTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "calendarTableViewCell")
        self.tableView!.registerNib(UINib(nibName: "CalendarTableHeaderView", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "CalendarTableHeaderViewIdentifier")
        var insets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height, 0, 0, 0)
        self.tableView!.contentInset = insets
        self.tableView!.scrollIndicatorInsets = insets
        
        dateFormatter.dateFormat = "MM.dd.yyyy"
        let from = dateFormatter.stringFromDate(NSDate())
        let to = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7))
        
        let url = NSURL(string: "https://fumc.herokuapp.com/api/calendars/all.json?from=\(from)&to=\(to)")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                // TODO
            } else {
                let eventsDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as [NSDictionary]
                for (var i = eventsDictionaries.count - 1; i >= 0; i--) {
                    let event = CalendarEvent(jsonDictionary: eventsDictionaries[i], dateFormatter: self.dateFormatter)
                    
                    self.dateFormatter.dateFormat = "EEEE, MMMM d"
                    var day = self.dateFormatter.stringFromDate(event.from)
                    if (self.events.indexForKey(day) != nil) {
                        self.events[day]!.append(event)
                    } else {
                        self.events[day] = [event]
                    }
                }
                
                self.sortedKeys = self.events.keys.array.sorted({ (a, b) -> Bool in
                    // TODO: this is incompatible with iOS < 8.0
                    return NSCalendar.currentCalendar().compareDate(self.dateFormatter.dateFromString(a)!, toDate: self.dateFormatter.dateFromString(b)!, toUnitGranularity: NSCalendarUnit.DayCalendarUnit) == NSComparisonResult.OrderedAscending
                })
                
                self.tableView!.reloadData()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.pageViewController!.didTransitionToViewController(self)
        self.pageViewController!.navigationItem.title = "Calendar"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow() {
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        self.pageViewController!.pageControl.hidden = false
        self.navigationController!.navigationBar.setTitleVerticalPositionAdjustment(-8, forBarMetrics: UIBarMetrics.Default)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func eventForIndexPath(indexPath: NSIndexPath) -> CalendarEvent {
        return self.events[self.sortedKeys[indexPath.section]]![indexPath.row]
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.events.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events[self.sortedKeys[section]]!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("calendarTableViewCell", forIndexPath: indexPath) as CalendarTableViewCell
        let event = eventForIndexPath(indexPath)
        cell.titleLabel!.text = event.name
        cell.locationLabel!.text = event.location
        
        self.dateFormatter.dateFormat = "h:mm"
        cell.timeLabel!.text = self.dateFormatter.stringFromDate(event.from)
        self.dateFormatter.dateFormat = "a"
        cell.meridiemLabel!.text = self.dateFormatter.stringFromDate(event.from)

        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CalendarTableHeaderViewIdentifier") as CalendarTableHeaderView
        header.label!.text = self.sortedKeys[section]
        return header
    }

    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("eventSegue", sender: indexPath)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventSegue") {
            self.pageViewController!.pageControl.hidden = true
            (segue.destinationViewController as EventViewController).calendarEvent = eventForIndexPath(self.tableView!.indexPathForSelectedRow()!)
        }
    }

}
