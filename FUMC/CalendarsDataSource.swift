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
    
    func requestCalendars(completed: () -> Void = { }) {
        let url = NSURL(string: "https://fumc.herokuapp.com/api/calendars/list")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil || (response as NSHTTPURLResponse).statusCode != 200) {
                ErrorAlerter.loadingAlertBasedOnReachability().show()
                completed()
            } else {
                var error: NSError?
                let calendarDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as [NSDictionary]
                if (error != nil) {
                    ErrorAlerter.loadingAlertBasedOnReachability().show()
                    completed()
                    return
                }
                
                self.calendars.removeAll(keepCapacity: true)
                for json in calendarDictionaries {
                    self.calendars.append(Calendar(jsonDictionary: json))
                }
                completed()
            }
        }
    }
    
    func indexPathForCalendarId(id: String) -> NSIndexPath? {
        if let index = find(self.calendars.map { $0.id }, id) {
            return NSIndexPath(forRow: index, inSection: 1)
        }
        return nil
    }
    
    func calendarForIndexPath(indexPath: NSIndexPath) -> Calendar? {
        return self.calendars[indexPath.row]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.calendars.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("calendarSettingsTableViewCell", forIndexPath: indexPath) as CalendarSettingsTableViewCell
        
        let calendar = self.calendars[indexPath.row]
        cell.label!.text = calendar.name
        cell.color = calendar.color
        
        cell.label!.textColor = cell.color!
        cell.borderView!.layer.borderColor = cell.color!.CGColor
        cell.checkView!.tintColor = cell.color!

        return cell
    }

}
