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
            self.settingsDelegate!.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    func requestCalendars(completed: () -> Void = { }) {
        let url = NSURL(string: "https://fumc.herokuapp.com/api/calendars/list")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil || (response as NSHTTPURLResponse).statusCode != 200) {
                self.settingsDelegate?.dataSource(self, failedToLoadWithError: error)
            } else {
                var error: NSError?
                let calendarDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as [NSDictionary]
                if (error != nil) {
                    self.settingsDelegate?.dataSource(self, failedToLoadWithError: error)
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
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        var l: CGFloat = 0
        
        let transform: (CGFloat) -> CGFloat = { x in
            return (-pow(100, -x + 0.15) + 1) / 5 + 0.8
        }
        
        calendar.color.getHue(&h, saturation: &s, brightness: &l, alpha: nil)
        cell.checkView!.color = UIColor(hue: h, saturation: s, brightness: transform(l), alpha: 1)

        return cell
    }

}
