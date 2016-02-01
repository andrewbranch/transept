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
import Crashlytics

class EventViewController: UIViewController, EKEventEditViewDelegate, UITableViewDelegate, UIAlertViewDelegate {
    
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
    
    var eventButtonLabel: UILabel?
    var calendarEvent: CalendarEvent?
    var dateFormatter = NSDateFormatter()
    private var ekEvent: EKEvent? {
        didSet {
            if let label = self.eventButtonLabel {
                if (self.ekEvent == nil) {
                    label.text = "Add to calendar"
                } else {
                    label.text = "View in calendar"
                }
            }
        }
    }
    private lazy var eventStore: EKEventStore = {
        return EKEventStore()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatter.timeZone = NSTimeZone(abbreviation: "CST")
        self.navigationItem.title = "Event Detail"
        self.descriptionLabel!.font = UIFont.fumcMainFontRegular14
        self.dateContainer!.layer.cornerRadius = 10
        self.dateContainer!.layer.borderWidth = 3
        self.dateContainer!.layer.borderColor = UIColor(white: 54/255, alpha: 1).CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dateFormatter.dateFormat = "MMM"
        let fromString = self.dateFormatter.stringFromDate(self.calendarEvent!.from) as NSString
        self.monthLabel!.text = fromString.substringToIndex(3).uppercaseString
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
        
        let description = String(htmlEncodedString: self.calendarEvent!.descript)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        self.descriptionLabel!.attributedText = NSAttributedString(string: description, attributes: [
            NSParagraphStyleAttributeName: paragraphStyle
        ])
        
        if let image = self.calendarEvent!.calendar.defaultImage {
            UIView.transitionWithView(self.imageView!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.imageView!.image = image
            }, completion: nil)
        }
        
        if (EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) == EKAuthorizationStatus.Authorized) {
            self.tryMatchingEvent()
        }
        
        #if !DEBUG
        Answers.logCustomEventWithName("Viewed event", customAttributes: [
            "Name": self.calendarEvent!.name,
            "Calendar": self.calendarEvent!.calendar.name,
            "Id": self.calendarEvent!.id
        ])
        #endif
    }
    
    func addEvent() {
        guard EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) != EKAuthorizationStatus.Denied else {
            let alert = UIAlertView(title: "Calendar Access Denied", message: "It looks like you’ve previously chosen not to allow this app to access your calendar. You can change that in Settings.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings")
            alert.show()
            return
        }
        
        self.eventStore.requestAccessToEntityType(EKEntityType.Event) { granted, error in
            if (error != nil) {
                let alert = UIAlertView(title: "Error Accessing Calendar", message: "Hmm. There was a problem accessing your calendar. Sorry!", delegate: nil, cancelButtonTitle: "Cancel")
                alert.show()
            } else if (granted) {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = self.calendarEvent!.name
                event.startDate = self.calendarEvent!.from
                event.endDate = self.calendarEvent!.to
                event.location = self.calendarEvent!.location
                event.allDay = self.calendarEvent!.allDay
                self.ekEvent = event
                let eventViewController = EKEventEditViewController()
                eventViewController.eventStore = self.eventStore
                eventViewController.event = event
                eventViewController.editViewDelegate = self
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(eventViewController, animated: true, completion: nil)
                }
            } 
        }
    }
    
    func viewEvent(event: EKEvent) {
        let timestamp = event.startDate.timeIntervalSinceReferenceDate
        UIApplication.sharedApplication().openURL(NSURL(string: "calshow:\(timestamp)")!)
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction) {
        if (action == EKEventEditViewAction.Saved) {
            let alert = UIAlertView(title: "Event Saved", message: "\(self.calendarEvent!.name) has been saved to your calendar.", delegate: nil, cancelButtonTitle: "Close")
            alert.show()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let event = self.ekEvent {
            self.viewEvent(event)
        } else {
            self.addEvent()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tryMatchingEvent() {
        guard let calendarEvent = self.calendarEvent else {
            self.ekEvent = nil
            return
        }
        
        let predicate = self.eventStore.predicateForEventsWithStartDate(calendarEvent.from, endDate: calendarEvent.to, calendars: nil)
        self.eventStore.enumerateEventsMatchingPredicate(predicate) { (event, stop) -> Void in
            if (event.title == calendarEvent.name) {
                stop.initialize(true)
                self.ekEvent = event
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "addToCalendarEmbed") {
            let controller = segue.destinationViewController as! UITableViewController
            let cell = controller.tableView(controller.tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
            self.eventButtonLabel = cell.textLabel
            controller.tableView.delegate = self
        }
    }
    
    // MARK - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 1) {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
}
