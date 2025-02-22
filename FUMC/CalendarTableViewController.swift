//
//  CalendarTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/10/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import Crashlytics

protocol CalendarSettingsDelegate {
    func calendarsDataSource(dataSource: CalendarsDataSource, didGetCalendars calendars: [Calendar]) -> Void
    func calendarsDataSource(dataSource: CalendarsDataSource, failedGettingCalendarsWithError error: ErrorType) -> Void
    func calendarSettingsController(viewController: CalendarSettingsViewController, didUpdateSelectionFrom oldCalendars: [Calendar], to newCalendars: [Calendar]) -> Void
}

class CalendarTableViewController: CustomTableViewController, UITableViewDataSource, UITableViewDelegate, CalendarSettingsDelegate {
    
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
        return self.events.filteredDictionary { key, value in value.count > 0 }
    }
    var sortedKeys = [NSString]()
    let dateFormatter = NSDateFormatter()
    var currentCalendars = [Calendar]()
    var calendarsDataSource: CalendarsDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatter.timeZone = NSTimeZone(abbreviation: "CST")

        self.tableView!.registerNib(UINib(nibName: "CalendarTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "calendarTableViewCell")
        self.tableView!.registerNib(UINib(nibName: "CalendarTableViewAllDayCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "calendarTableViewAllDayCell")
        self.tableView!.registerNib(UINib(nibName: "CalendarTableHeaderView", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "CalendarTableHeaderViewIdentifier")
        
        self.calendarsDataSource = CalendarsDataSource(settingsDelegate: nil, calendarDelegate: self)
        self.showLoadingView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEventWithName("Viewed tab", customAttributes: ["Name": "Calendar"])
        #endif
    }
    
    func requestEventsForCalendars(calendars: [Calendar], page: Int, completed: () -> Void = { }) {
        if (calendars.count == 0) {
            completed()
            return
        }
        
        API.shared().getEventsForCalendars(calendars) { calendars, error in
            if (error != nil) {
                ErrorAlerter.showLoadingAlertInViewController(self)
                self.hideLoadingView()
            }
            completed()
        }
    }
    
    override func reloadData() {
        self.calendarsDataSource!.refresh()
        self.refreshControl.beginRefreshing()
        requestEventsForCalendars(self.currentCalendars, page: 1) {
            self.updateTableWithNewCalendars(self.currentCalendars)
            self.refreshControl.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func structureEventsFromCalendars(calendars: [Calendar]) -> Dictionary<NSDate, [CalendarEvent]> {
        var structured = Dictionary<NSDate, [CalendarEvent]>()
        let events = calendars.map({ $0.events }).reduce([], combine: +).sort({
            return NSCalendar.currentCalendar().compareDate($0.from, toDate: $1.from, toUnitGranularity: NSCalendarUnit.Minute) == NSComparisonResult.OrderedAscending
        })
        for (var i = 0; i < 7; i++) {
            let date = NSDate(timeIntervalSinceNow: 60 * 60 * 24 * Double(i)).midnight()
            structured[date] = events.filter { $0.from.midnight() == date }
        }
        return structured
    }
    
    func eventForIndexPath(indexPath: NSIndexPath) -> CalendarEvent {
        return self.displayEvents[self.displayEvents.keys.sort(<)[indexPath.section]]![indexPath.row]
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.displayEvents.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayEvents[self.displayEvents.keys.sort(<)[section]]!.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let event = eventForIndexPath(indexPath)
        if (event.allDay) {
            let cell = tableView.dequeueReusableCellWithIdentifier("calendarTableViewAllDayCell", forIndexPath: indexPath) as! CalendarTableViewAllDayCell
            cell.titleLabel!.text = event.name
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("calendarTableViewCell", forIndexPath: indexPath) as! CalendarTableViewCell
        cell.titleLabel!.text = event.name
        cell.locationLabel!.text = event.location
        
        let colorLayer = CALayer()
        colorLayer.frame = CGRectMake(-1, 0, 10, cell.frame.height + 1)
        colorLayer.backgroundColor = event.calendar.color.CGColor
        cell.contentView.layer.addSublayer(colorLayer)
        
        if (event.allDay) {
            cell.timeLabel!.text = "All day"
            cell.meridiemLabel!.text = ""
        } else {
            self.dateFormatter.dateFormat = "h:mm"
            cell.timeLabel!.text = self.dateFormatter.stringFromDate(event.from)
            self.dateFormatter.dateFormat = "a"
            cell.meridiemLabel!.text = self.dateFormatter.stringFromDate(event.from)
        }

        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CalendarTableHeaderViewIdentifier") as! CalendarTableHeaderView
        self.dateFormatter.dateFormat = "EEEE, MMMM d"
        header.label!.text = self.dateFormatter.stringFromDate(self.displayEvents.keys.sort(<)[section])
        return header
    }

    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("eventSegue", sender: indexPath)
    }
    
    // MARK: - Calendar Settings Delegate
    
    func calendarsDataSource(dataSource: CalendarsDataSource, didGetCalendars calendars: [Calendar]) {
        if let currentCalendarIds = NSUserDefaults.standardUserDefaults().objectForKey("selectedCalendarIds") as? [String] {
            self.currentCalendars = calendars.filter { currentCalendarIds.indexOf($0.id) != nil }
        } else {
            self.currentCalendars = calendars
            NSUserDefaults.standardUserDefaults().setObject(calendars.map { $0.id }, forKey: "selectedCalendarIds")
        }
        
        self.showLoadingView()
        requestEventsForCalendars(self.currentCalendars, page: 1) {
            self.updateTableWithNewCalendars(self.currentCalendars)
            self.hideLoadingView()
        }
    }
    
    func calendarsDataSource(dataSource: CalendarsDataSource, failedGettingCalendarsWithError error: ErrorType) {
        ErrorAlerter.loadingAlertBasedOnReachability().show()
        self.hideLoadingView()
    }
    
    func calendarSettingsController(viewController: CalendarSettingsViewController, didUpdateSelectionFrom oldCalendars: [Calendar], to newCalendars: [Calendar]) {
        self.showLoadingView()
        self.currentCalendars = newCalendars
        let diffCalendars = newCalendars.filter { oldCalendars.indexOf($0) == nil }
        requestEventsForCalendars(diffCalendars, page: 1) {
            self.updateTableWithNewCalendars(newCalendars)
            self.hideLoadingView()
        }
    }
    
    func updateTableWithNewCalendars(calendars: [Calendar]) {
        
        let newEvents = self.structureEventsFromCalendars(calendars)
        self.tableView!.beginUpdates()
        
        // Delete
        let sectionsToDelete = NSMutableIndexSet()
        let currentSections = self.events.filteredDictionary { key, value in value.count > 0 }
        let removedEntries = self.events.filteredDictionary { key, value in
            value.count > 0 && newEvents[key]!.count == 0
        }
        removedEntries.each { key, value in
            sectionsToDelete.addIndex(currentSections.keys.sort(<).indexOf(key)!)
        }
        self.tableView!.deleteSections(sectionsToDelete, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        var rowsToDelete = [NSIndexPath]()
        let remainingEntries = self.events.filteredDictionary { key, value in !removedEntries.has(key) && value.count > 0 }
        var entriesAfterRowRemove = Dictionary<NSDate, [CalendarEvent]>()
        remainingEntries.each { key, value in
            let entriesToDelete = value.filter {
                !newEvents[key]!.contains($0)
            }
            entriesAfterRowRemove[key] = value - entriesToDelete
            let section = currentSections.keys.sort(<).indexOf(key)!
            rowsToDelete.appendContentsOf(entriesToDelete.map {
                NSIndexPath(forRow: value.indexOf($0)!, inSection: section)
            })
        }
        self.tableView!.deleteRowsAtIndexPaths(rowsToDelete, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        
        // Insert
        let sectionsToInsert = NSMutableIndexSet()
        let insertedEntries = newEvents.filteredDictionary { key, value in
            value.count > 0 && self.events[key]!.count == 0
        }
        let union = remainingEntries.union(insertedEntries)
        insertedEntries.each { key, value in
            sectionsToInsert.addIndex(union.keys.sort(<).indexOf(key)!)
        }
        self.tableView!.insertSections(sectionsToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        var rowsToInsert = [NSIndexPath]()
        entriesAfterRowRemove.each { key, value in
            let entriesToInsert = newEvents[key]!.filter { !value.contains($0) }
            let combined = (value + entriesToInsert).sort {
                if ($0.0.from < $0.1.from) { return true }
                if ($0.0.from > $0.1.from) { return false }
                return $0.0.name <= $0.1.name
            }
            let section = union.keys.sort(<).indexOf(key)!
            rowsToInsert.appendContentsOf(entriesToInsert.map {
                NSIndexPath(forRow: combined.indexOf($0)!, inSection: section)
            })
        }
        self.tableView!.insertRowsAtIndexPaths(rowsToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        self.events = newEvents
        self.tableView!.endUpdates()
        
        self.tableView!.backgroundView?.hidden = self.displayEvents.count > 0
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventSegue") {
            (segue.destinationViewController as! EventViewController).calendarEvent = eventForIndexPath(self.tableView!.indexPathForSelectedRow!)
        } else if (segue.identifier == "calendarSettingsSegue") {
            let viewController = (segue.destinationViewController as! CalendarSettingsViewController)
            self.calendarsDataSource!.settingsDelegate = viewController
            viewController.dataSource = self.calendarsDataSource
            viewController.delegate = self
        }
    }

}
