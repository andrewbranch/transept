//
//  BulletinsDataSource.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/29/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class BulletinsDataSource: NSObject, MediaTableViewDataSource {
    
    var title: NSString = "Worship Bulletins"
    let url = NSURL(string: "https://fumc.herokuapp.com/api/bulletins?visible=true")
    var bulletins: Dictionary<NSString, [Bulletin]> = Dictionary<NSString, [Bulletin]>()
    let dateFormatter = NSDateFormatter()
    var sortedKeys: [NSString]?
    
    override init() {
        super.init()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        var request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                // TODO
            } else {
                var bulletinsDictionary: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as [NSDictionary]
                for (var i = 0; i < bulletinsDictionary.count; i++) {

                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                    var date = self.dateFormatter.dateFromString(bulletinsDictionary[i].objectForKey("date") as String)
                    
                    var b = Bulletin()
                    b.setValuesForKeysWithDictionary(bulletinsDictionary[i])
                    b.date = date!
                    
                    self.dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                    var day = self.dateFormatter.stringFromDate(b.date)
                    if (self.bulletins.indexForKey(day) != nil) {
                        self.bulletins[day]!.append(b)
                    } else {
                        self.bulletins[day] = [b]
                    }
                }
                
                self.sortedKeys = self.bulletins.keys.array
                self.sortedKeys?.sort {
                    calendar?.compareDate(self.dateFormatter.dateFromString($0)!, toDate: self.dateFormatter.dateFromString($1)!, toUnitGranularity: NSCalendarUnit.DayCalendarUnit) == NSComparisonResult.OrderedDescending
                }
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.bulletins.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bulletins[self.sortedKeys![section]]!.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
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
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
}
