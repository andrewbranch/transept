//
//  CalendarTableViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/10/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CalendarTableViewController: UIViewController, UITableViewDataSource {
    
    var events: Dictionary<NSString, [CalendarEvent]> = Dictionary<NSString, [CalendarEvent]>()
    var sortedKeys = [NSString]()
    let dateFormatter = NSDateFormatter()
    @IBOutlet var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView!.dataSource = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier("calendarTableCell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel.text = eventForIndexPath(indexPath).name

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sortedKeys[section]
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
