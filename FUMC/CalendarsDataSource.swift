//
//  CalendarsDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 12/5/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//



class CalendarsDataSource: NSObject, UITableViewDataSource {
    
    var calendars = [Calendar]()
    var settingsDelegate: CalendarsDataSourceDelegate?
    var calendarDelegate: CalendarTableViewController?
    
    required init(settingsDelegate: CalendarsDataSourceDelegate?, calendarDelegate: CalendarTableViewController) {
        super.init()
        self.settingsDelegate = settingsDelegate
        self.calendarDelegate = calendarDelegate
        requestCalendars() {
            calendarDelegate.calendarsDataSource(self, didGetCalendars: self.calendars)
            self.settingsDelegate?.dataSourceDidFinishLoadingAPI(self)
            return
        }
    }
    
    func refresh() {
        requestCalendars() {
            self.settingsDelegate?.dataSourceDidFinishLoadingAPI(self)
            self.calendarDelegate!.calendarsDataSource(self, didGetCalendars: self.calendars)
        }
    }
    
    func requestCalendars(_ completed: @escaping () -> Void = { }) {
        API.shared().getCalendars() { calendars, error in
            if (error != nil) {
                self.settingsDelegate?.dataSource(self, failedToLoadWithError: error as? NSError)
                self.calendarDelegate!.calendarsDataSource(self, failedGettingCalendarsWithError: error!)
            } else {
                self.calendars = calendars
                completed()
            }
            
        }
    }
    
    func indexPathForCalendarId(_ id: String) -> IndexPath? {
        if let index = self.calendars.map({ $0.id }).index(of: id) {
            return IndexPath(row: index + 1, section: 0)
        }
        return nil
    }
    
    func calendarForIndexPath(_ indexPath: IndexPath) -> Calendar? {
        if (indexPath.row == 0) { return nil }
        return self.calendars[indexPath.row - 1]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calendars.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectCell") as! CalendarSettingsSelectTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarSettingsTableViewCell", for: indexPath) as! CalendarSettingsTableViewCell
        let calendar = calendarForIndexPath(indexPath)!
        cell.label!.text = calendar.name
        cell.checkView!.color = calendar.color

        return cell
    }

}
