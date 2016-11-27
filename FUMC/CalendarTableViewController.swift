//
//  CalendarTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/10/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import Crashlytics
import EZSwiftExtensions

protocol CalendarSettingsDelegate {
    func calendarsDataSource(_ dataSource: CalendarsDataSource, didGetCalendars calendars: [Calendar]) -> Void
    func calendarsDataSource(_ dataSource: CalendarsDataSource, failedGettingCalendarsWithError error: Error) -> Void
    func calendarSettingsController(_ viewController: CalendarSettingsViewController, didUpdateSelectionFrom oldCalendars: [Calendar], to newCalendars: [Calendar]) -> Void
}

class CalendarTableViewController: CustomTableViewController, UITableViewDataSource, UITableViewDelegate, CalendarSettingsDelegate {
    
    lazy var events: Dictionary<Date, [CalendarEvent]> = {
        return [
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 0).midnight(): [],
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 1).midnight(): [],
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 2).midnight(): [],
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 3).midnight(): [],
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 4).midnight(): [],
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 5).midnight(): [],
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 6).midnight(): []
        ]
    }()
    var displayEvents: Dictionary<Date, [CalendarEvent]> {
        return self.events.filter { key, value in value.count > 0 }
    }
    var sortedKeys = [NSString]()
    let dateFormatter = DateFormatter()
    var currentCalendars = [Calendar]()
    var calendarsDataSource: CalendarsDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatter.timeZone = TimeZone(abbreviation: "CST")

        self.tableView!.register(UINib(nibName: "CalendarTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "calendarTableViewCell")
        self.tableView!.register(UINib(nibName: "CalendarTableViewAllDayCell", bundle: Bundle.main), forCellReuseIdentifier: "calendarTableViewAllDayCell")
        self.tableView!.register(UINib(nibName: "CalendarTableHeaderView", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "CalendarTableHeaderViewIdentifier")
        
        self.calendarsDataSource = CalendarsDataSource(settingsDelegate: nil, calendarDelegate: self)
        self.showLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEvent(withName: "Viewed tab", customAttributes: ["Name": "Calendar"])
        #endif
    }
    
    func requestEventsForCalendars(_ calendars: [Calendar], page: Int, completed: @escaping () -> Void = { }) {
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
    
    func structureEventsFromCalendars(_ calendars: [Calendar]) -> Dictionary<Date, [CalendarEvent]> {
        var structured = Dictionary<Date, [CalendarEvent]>()
        let events = calendars.map({ $0.events }).reduce([], +).sorted(by: {
            return (Foundation.Calendar.current as NSCalendar).compare($0.from as Date, to: $1.from as Date, toUnitGranularity: NSCalendar.Unit.minute) == ComparisonResult.orderedAscending
        })
        for i in 0 ..< 7 {
            let date = Date(timeIntervalSinceNow: 60 * 60 * 24 * Double(i)).midnight()
            structured[date] = events.filter { $0.from.midnight() == date }
        }
        return structured
    }
    
    func eventForIndexPath(_ indexPath: IndexPath) -> CalendarEvent {
        return self.displayEvents[self.displayEvents.keys.sorted(by: <)[indexPath.section]]![indexPath.row]
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.displayEvents.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayEvents[self.displayEvents.keys.sorted(by: <)[section]]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let event = eventForIndexPath(indexPath)
        if (event.allDay) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableViewAllDayCell", for: indexPath) as! CalendarTableViewAllDayCell
            cell.titleLabel!.text = event.name
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableViewCell", for: indexPath) as! CalendarTableViewCell
        cell.titleLabel!.text = event.name
        cell.locationLabel!.text = event.location
        
        let colorLayer = CALayer()
        colorLayer.frame = CGRect(x: -1, y: 0, width: 10, height: cell.frame.height + 1)
        colorLayer.backgroundColor = event.calendar.color.cgColor
        cell.contentView.layer.addSublayer(colorLayer)
        
        if (event.allDay) {
            cell.timeLabel!.text = "All day"
            cell.meridiemLabel!.text = ""
        } else {
            self.dateFormatter.dateFormat = "h:mm"
            cell.timeLabel!.text = self.dateFormatter.string(from: event.from as Date)
            self.dateFormatter.dateFormat = "a"
            cell.meridiemLabel!.text = self.dateFormatter.string(from: event.from as Date)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CalendarTableHeaderViewIdentifier") as! CalendarTableHeaderView
        self.dateFormatter.dateFormat = "EEEE, MMMM d"
        header.label!.text = self.dateFormatter.string(from: self.displayEvents.keys.sorted(by: <)[section])
        return header
    }

    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "eventSegue", sender: indexPath)
    }
    
    // MARK: - Calendar Settings Delegate
    
    func calendarsDataSource(_ dataSource: CalendarsDataSource, didGetCalendars calendars: [Calendar]) {
        if let currentCalendarIds = UserDefaults.standard.object(forKey: "selectedCalendarIds") as? [String] {
            self.currentCalendars = calendars.filter { currentCalendarIds.index(of: $0.id) != nil }
        } else {
            self.currentCalendars = calendars
            UserDefaults.standard.set(calendars.map { $0.id }, forKey: "selectedCalendarIds")
        }
        
        self.showLoadingView()
        requestEventsForCalendars(self.currentCalendars, page: 1) {
            self.updateTableWithNewCalendars(self.currentCalendars)
            self.hideLoadingView()
        }
    }
    
    func calendarsDataSource(_ dataSource: CalendarsDataSource, failedGettingCalendarsWithError error: Error) {
        ErrorAlerter.loadingAlertBasedOnReachability().show()
        self.hideLoadingView()
    }
    
    func calendarSettingsController(_ viewController: CalendarSettingsViewController, didUpdateSelectionFrom oldCalendars: [Calendar], to newCalendars: [Calendar]) {
        self.showLoadingView()
        self.currentCalendars = newCalendars
        let diffCalendars = newCalendars.filter { oldCalendars.index(of: $0) == nil }
        requestEventsForCalendars(diffCalendars, page: 1) {
            self.updateTableWithNewCalendars(newCalendars)
            self.hideLoadingView()
        }
    }
    
    func updateTableWithNewCalendars(_ calendars: [Calendar]) {
        
        let newEvents = self.structureEventsFromCalendars(calendars)
        self.tableView!.beginUpdates()
        
        // Delete
        let sectionsToDelete = NSMutableIndexSet()
        let currentSections = self.events.filter { key, value in value.count > 0 }
        let removedEntries = self.events.filter { key, value in
            value.count > 0 && newEvents[key]!.count == 0
        }
        removedEntries.forEach { key, value in
            sectionsToDelete.add(currentSections.keys.sorted(by: <).index(of: key)!)
        }
        self.tableView!.deleteSections(sectionsToDelete as IndexSet, with: UITableViewRowAnimation.automatic)
        
        var rowsToDelete = [IndexPath]()
        let remainingEntries = self.events.filter { key, value in !removedEntries.has(key) && value.count > 0 }
        var entriesAfterRowRemove = Dictionary<Date, [CalendarEvent]>()
        remainingEntries.forEach { key, value in
            let entriesToDelete = value.filter {
                !newEvents[key]!.contains($0)
            }
            entriesAfterRowRemove[key] = value.difference(entriesToDelete)
            let section = currentSections.keys.sorted(by: <).index(of: key)!
            rowsToDelete.append(contentsOf: entriesToDelete.map {
                IndexPath(row: value.index(of: $0)!, section: section)
            })
        }
        self.tableView!.deleteRows(at: rowsToDelete, with: UITableViewRowAnimation.automatic)
        
        
        // Insert
        let sectionsToInsert = NSMutableIndexSet()
        let insertedEntries = newEvents.filter { key, value in
            value.count > 0 && self.events[key]!.count == 0
        }
        let union = remainingEntries.union(insertedEntries)
        insertedEntries.forEach { key, value in
            sectionsToInsert.add(union.keys.sorted(by: <).index(of: key)!)
        }
        self.tableView!.insertSections(sectionsToInsert as IndexSet, with: UITableViewRowAnimation.automatic)
        
        var rowsToInsert = [IndexPath]()
        entriesAfterRowRemove.forEach { key, value in
            let entriesToInsert = newEvents[key]!.filter { !value.contains($0) }
            let combined = (value + entriesToInsert).sorted {
                if ($0.0.from < $0.1.from) { return true }
                if ($0.0.from > $0.1.from) { return false }
                return $0.0.name <= $0.1.name
            }
            let section = union.keys.sorted(by: <).index(of: key)!
            rowsToInsert.append(contentsOf: entriesToInsert.map {
                IndexPath(row: combined.index(of: $0)!, section: section)
            })
        }
        self.tableView!.insertRows(at: rowsToInsert, with: UITableViewRowAnimation.automatic)
        
        self.events = newEvents
        self.tableView!.endUpdates()
        
        self.tableView!.backgroundView?.isHidden = self.displayEvents.count > 0
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "eventSegue") {
            (segue.destination as! EventViewController).calendarEvent = eventForIndexPath(self.tableView!.indexPathForSelectedRow!)
        } else if (segue.identifier == "calendarSettingsSegue") {
            let viewController = (segue.destination as! CalendarSettingsViewController)
            self.calendarsDataSource!.settingsDelegate = viewController
            viewController.dataSource = self.calendarsDataSource
            viewController.delegate = self
        }
    }
    
    
    func resetAccessRequests() {
        API.shared().accessToken = nil
        UserDefaults.standard.setValue(nil, forKey: "directoryAccessRequestId")
    }

}
