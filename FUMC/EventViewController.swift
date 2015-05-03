//
//  EventViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/12/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class EventViewController: UIViewController, EKEventEditViewDelegate, UITableViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet var dateContainer: UIVisualEffectView?
    @IBOutlet var monthLabel: UILabel?
    @IBOutlet var dayLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var locationLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var fromTimeLabel: UILabel?
    @IBOutlet var fromMeridiemLabel: UILabel?
    @IBOutlet var toTimeLabel: UILabel?
    @IBOutlet var toMeridiemLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet var imageView: UIImageView?
    
    var calendarEvent: CalendarEvent?
    var dateFormatter = NSDateFormatter()
    private var ekEvent: EKEvent?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatter.timeZone = NSTimeZone(abbreviation: "CST")
        self.navigationItem.title = "Event Detail"
        self.descriptionLabel!.font = UIFont.fumcMainFontRegular14
        self.dateContainer!.layer.cornerRadius = 10
        self.dateContainer!.layer.borderWidth = 3
        self.dateContainer!.layer.borderColor = UIColor(white: 54/255, alpha: 1).CGColor
        if let savedEventIds = NSUserDefaults.standardUserDefaults().objectForKey("savedEventIds") as? [String] {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dateFormatter.dateFormat = "MMM"
        self.monthLabel!.text = String(Array(self.dateFormatter.stringFromDate(self.calendarEvent!.from))[0...2]).uppercaseString
        self.dateFormatter.dateFormat = "dd"
        self.dayLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        self.titleLabel!.text = self.calendarEvent!.name
        
        self.locationLabel!.text = self.calendarEvent!.location
        self.dateFormatter.dateFormat = "EEEE, MMMM d yyyy"
        self.dateLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        
        if (self.calendarEvent!.allDay) {
            self.fromTimeLabel!.superview!.subviews.each { (view: AnyObject) in (view as! UIView).hidden = true }
            self.fromTimeLabel!.hidden = false
            self.fromTimeLabel!.text = "All day"
        } else {
            self.dateFormatter.dateFormat = "h:mm"
            self.fromTimeLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
            self.toTimeLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.to)
            self.dateFormatter.dateFormat = "a"
            self.fromMeridiemLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
            self.toMeridiemLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.to)
        }
        
        let description = WSLHTMLEntities.convertHTMLtoString(self.calendarEvent!.descript)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        self.descriptionLabel!.attributedText = NSAttributedString(string: description, attributes: [
            NSParagraphStyleAttributeName: paragraphStyle
        ])
        
        if let image = self.calendarEvent!.calendar.defaultImage {
            UIView.transitionWithView(self.imageView!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.imageView!.image = image
            }, completion: nil)
        }
    }
    
    func addEvent() {
        let eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(EKEntityTypeEvent) { granted, error in
            if (error != nil) {
                let alert = UIAlertView(title: "Error Accessing Calendar", message: "Hmm. There was a problem accessing your calendar. Sorry!", delegate: nil, cancelButtonTitle: "Cancel")
                alert.show()
            }
            if (granted) {
                let event = EKEvent(eventStore: eventStore)
                event.title = self.calendarEvent!.name
                event.startDate = self.calendarEvent!.from
                event.endDate = self.calendarEvent!.to
                event.location = self.calendarEvent!.location
                event.allDay = self.calendarEvent!.allDay
                self.ekEvent = event
                let eventViewController = EKEventEditViewController()
                eventViewController.eventStore = eventStore
                eventViewController.event = event
                eventViewController.editViewDelegate = self
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(eventViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func eventEditViewController(controller: EKEventEditViewController!, didCompleteWithAction action: EKEventEditViewAction) {
        if (action.value == EKEventEditViewActionSaved.value) {
            let alert = UIAlertView(title: "Event Saved", message: "\(self.calendarEvent!.name) has been saved to your calendar.", delegate: nil, cancelButtonTitle: "Close")
            alert.show()
//            if let savedEventIds = NSUserDefaults.standardUserDefaults().objectForKey("savedEventIds") as? [String] {
//                NSUserDefaults.standardUserDefaults().setObject(savedEventIds + [self.ekEvent!.eventIdentifier], forKey: "savedEventIds")
//            } else {
//                NSUserDefaults.standardUserDefaults().setObject([self.ekEvent!.eventIdentifier], forKey: "savedEventIds")
//            }
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.addEvent()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "addToCalendarEmbed") {
            (segue.destinationViewController as! UITableViewController).tableView.delegate = self
        }
    }
    
}
