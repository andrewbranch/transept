//
//  CalendarTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/10/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

protocol CalendarSettingsDelegate {
    func calendarsDataSource(dataSource: CalendarsDataSource, didGetCalendars calendars: [Calendar]) -> Void
    func calendarSettingsController(viewController: CalendarSettingsViewController, didUpdateSelectionFrom oldCalendars: [Calendar], to newCalendars: [Calendar]) -> Void
}

class CalendarTableViewController: CustomTableViewController, UITableViewDataSource, UITableViewDelegate, CalendarSettingsDelegate, HomeViewPage {
    
    var pageViewController: HomeViewController?
    lazy var events: Dictionary<NSDate, [CalendarEvent]> = {
        return [
            NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 0).midnight(): [],
            NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 1).midnight(): [],
            NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 2).midnight(): [],
            NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 3).midnight(): [],
            NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 4).midnight(): [],
            NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 5).midnight(): [],
            NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 6).midnight(): []
        ]
    }()
    var displayEvents: Dictionary<NSDate, [CalendarEvent]> {
        return self.events.filter { key, value in value.count > 0 }
    }
    var sortedKeys = [NSString]()
    let dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView!.registerNib(UINib(nibName: "CalendarTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "calendarTableViewCell")
        self.tableView!.registerNib(UINib(nibName: "CalendarTableHeaderView", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "CalendarTableHeaderViewIdentifier")
        
        self.showLoadingView()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.pageViewController!.didTransitionToViewController(self)
        self.pageViewController!.navigationItem.title = "Calendar"
        UIView.animateWithDuration(0.25) {
            self.pageViewController!.pageControl.alpha = 1
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow() {
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func requestEventsForCalendars(calendars: [Calendar], page: Int, completed: () -> Void = { }) {
        if (calendars.count == 0) {
            completed()
            return
        }
        
        self.dateFormatter.dateFormat = "MM.dd.yyyy"
        let from = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page - 1)))
        let to = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page)))
        
        var requestsCompleted = 0
        var requestsFailed = 0
        let fail = { (completed: () -> Void) -> Void in
            requestsFailed++
            if (requestsCompleted + requestsFailed == calendars.count) {
                completed()
                ErrorAlerter.loadingAlertBasedOnReachability().show()
            }
        }
        
        for calendar in calendars {
            let url = NSURL(string: "https://fumc.herokuapp.com/api/calendars/\(calendar.id).json?from=\(from)&to=\(to)")
            let request = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                if (error != nil || (response as NSHTTPURLResponse).statusCode != 200) {
                    fail(completed)
                } else {
                    var error: NSError?
                    let eventDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as [NSDictionary]
                    if (error != nil) {
                        fail(completed)
                        return
                    }
                    
                    let dateFormatter = NSDateFormatter()
                    calendar.events.removeAll(keepCapacity: true)
                    for json in eventDictionaries {
                        calendar.events.append(CalendarEvent(jsonDictionary: json, dateFormatter: dateFormatter))
                    }
                    
                    requestsCompleted++
                    if (requestsCompleted + requestsFailed == calendars.count) {
                        completed()
                    }
                }
            }
        }
    }
    
//    override func reloadData() {
//        self.events.removeAll(keepCapacity: true)
//        requestEventsForCurrentCalendars()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func structureEventsFromCalendars(calendars: [Calendar]) -> Dictionary<NSDate, [CalendarEvent]> {
        var structured = Dictionary<NSDate, [CalendarEvent]>()
        let events = calendars.map({ $0.events }).reduce([], combine: +).sorted({
            return NSCalendar.currentCalendar().compareDate($0.from, toDate: $1.from, toUnitGranularity: NSCalendarUnit.MinuteCalendarUnit) == NSComparisonResult.OrderedAscending
        })
        for (var i = 0; i < 7; i++) {
            let date = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * Double(i)).midnight()
            structured[date] = events.filter { $0.from.midnight() == date }
        }
        return structured
    }
    
    func eventForIndexPath(indexPath: NSIndexPath) -> CalendarEvent {
        return self.displayEvents[self.displayEvents.keys.array.sorted(<)[indexPath.section]]![indexPath.row]
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.displayEvents.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayEvents[self.displayEvents.keys.array.sorted(<)[section]]!.count
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
        self.dateFormatter.dateFormat = "EEEE, MMMM d"
        header.label!.text = self.dateFormatter.stringFromDate(self.displayEvents.keys.array.sorted(<)[section])
        return header
    }

    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("eventSegue", sender: indexPath)
    }
    
    // MARK: - Calendar Settings Delegate
    
    func calendarsDataSource(dataSource: CalendarsDataSource, didGetCalendars calendars: [Calendar]) {
        var currentCalendars: [Calendar]
        if let currentCalendarIds = NSUserDefaults.standardUserDefaults().objectForKey("selectedCalendarIds") as? [String] {
            currentCalendars = calendars.filter { find(currentCalendarIds, $0.id) != nil }
        } else {
            currentCalendars = calendars
        }
        
        self.showLoadingView()
        requestEventsForCalendars(currentCalendars, page: 1) {
            self.updateTableWithNewCalendars(currentCalendars)
            self.hideLoadingView()
        }
    }
    
    func calendarSettingsController(viewController: CalendarSettingsViewController, didUpdateSelectionFrom oldCalendars: [Calendar], to newCalendars: [Calendar]) {
        self.showLoadingView()
        let diffCalendars = newCalendars.filter { find(oldCalendars, $0) == nil }
        requestEventsForCalendars(diffCalendars, page: 1) {
            self.updateTableWithNewCalendars(newCalendars)
            self.hideLoadingView()
        }
    }
    
    func updateTableWithNewCalendars(calendars: [Calendar]) {
        
        let newEvents = self.structureEventsFromCalendars(calendars)
        self.tableView!.beginUpdates()
        
        // Delete
        var sectionsToDelete = NSMutableIndexSet()
        let currentSections = self.events.filter { key, value in value.count > 0 }
        let removedEntries = self.events.filter { key, value in
            value.count > 0 && newEvents[key]!.count == 0
        }
        removedEntries.each { key, value in
            sectionsToDelete.addIndex(currentSections.keys.array.sorted(<).indexOf(key)!)
        }
        self.tableView!.deleteSections(sectionsToDelete, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        var rowsToDelete = [NSIndexPath]()
        let remainingEntries = self.events.filter { key, value in !removedEntries.has(key) && value.count > 0 }
        var entriesAfterRowRemove = Dictionary<NSDate, [CalendarEvent]>()
        remainingEntries.each { key, value in
            let entriesToDelete = value.filter {
                !newEvents[key]!.contains($0)
            }
            entriesAfterRowRemove[key] = value - entriesToDelete
            let section = currentSections.keys.array.sorted(<).indexOf(key)!
            rowsToDelete.extend(entriesToDelete.map {
                NSIndexPath(forRow: value.indexOf($0)!, inSection: section)
            })
        }
        self.tableView!.deleteRowsAtIndexPaths(rowsToDelete, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        
        // Insert
        var sectionsToInsert = NSMutableIndexSet()
        let insertedEntries = newEvents.filter { key, value in
            value.count > 0 && self.events[key]!.count == 0
        }
        let union = remainingEntries.union(insertedEntries)
        insertedEntries.each { key, value in
            sectionsToInsert.addIndex(union.keys.array.sorted(<).indexOf(key)!)
        }
        self.tableView!.insertSections(sectionsToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        var rowsToInsert = [NSIndexPath]()
        entriesAfterRowRemove.each { key, value in
            let entriesToInsert = newEvents[key]!.filter { !value.contains($0) }
            let combined = (value + entriesToInsert).sorted {
                if ($0.0.from < $0.1.from) { return true }
                if ($0.0.from > $0.1.from) { return false }
                return $0.0.name <= $0.1.name
            }
            let section = union.keys.array.sorted(<).indexOf(key)!
            rowsToInsert.extend(entriesToInsert.map {
                NSIndexPath(forRow: combined.indexOf($0)!, inSection: section)
            })
        }
        self.tableView!.insertRowsAtIndexPaths(rowsToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        self.events = newEvents
        self.tableView!.endUpdates()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventSegue") {
            UIView.animateWithDuration(0.25) {
                self.pageViewController!.pageControl.alpha = 0
            }
            (segue.destinationViewController as EventViewController).calendarEvent = eventForIndexPath(self.tableView!.indexPathForSelectedRow()!)
        }
    }

}
