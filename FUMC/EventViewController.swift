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
    var dateFormatter = DateFormatter()
    fileprivate var ekEvent: EKEvent? {
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
    fileprivate lazy var eventStore: EKEventStore = {
        return EKEventStore()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatter.timeZone = TimeZone(abbreviation: "CST")
        self.navigationItem.title = "Event Detail"
        self.descriptionLabel!.font = UIFont.fumcMainFontRegular14
        self.dateContainer!.layer.cornerRadius = 10
        self.dateContainer!.layer.borderWidth = 3
        self.dateContainer!.layer.borderColor = UIColor(white: 54/255, alpha: 1).cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dateFormatter.dateFormat = "MMM"
        let fromString = self.dateFormatter.string(from: self.calendarEvent!.from as Date) as NSString
        self.monthLabel!.text = fromString.substring(to: 3).uppercased()
        self.dateFormatter.dateFormat = "dd"
        self.dayLabel!.text = self.dateFormatter.string(from: self.calendarEvent!.from as Date)
        self.titleLabel!.text = self.calendarEvent!.name
        
        self.locationLabel!.text = self.calendarEvent!.location
        self.dateFormatter.dateFormat = "EEEE, MMMM d yyyy"
        self.dateLabel!.text = self.dateFormatter.string(from: self.calendarEvent!.from as Date)
        
        if (self.calendarEvent!.allDay) {
            self.fromTimeLabel!.superview!.subviews.forEach { $0.isHidden = true }
            self.fromTimeLabel!.isHidden = false
            self.fromTimeLabel!.text = "All day"
        } else {
            self.dateFormatter.dateFormat = "h:mm"
            self.fromTimeLabel!.text = self.dateFormatter.string(from: self.calendarEvent!.from as Date)
            self.toTimeLabel!.text = self.dateFormatter.string(from: self.calendarEvent!.to as Date)
            self.dateFormatter.dateFormat = "a"
            self.fromMeridiemLabel!.text = self.dateFormatter.string(from: self.calendarEvent!.from as Date)
            self.toMeridiemLabel!.text = self.dateFormatter.string(from: self.calendarEvent!.to as Date)
        }
        
        let description = String(htmlEncodedString: self.calendarEvent!.descript)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        self.descriptionLabel!.attributedText = NSAttributedString(string: description, attributes: [
            NSParagraphStyleAttributeName: paragraphStyle
        ])
        
        if let image = self.calendarEvent!.calendar.defaultImage {
            UIView.transition(with: self.imageView!, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.imageView!.image = image
            }, completion: nil)
        }
        
        if (EKEventStore.authorizationStatus(for: EKEntityType.event) == EKAuthorizationStatus.authorized) {
            self.tryMatchingEvent()
        }
        
        #if !DEBUG
        Answers.logCustomEvent(withName: "Viewed event", customAttributes: [
            "Name": self.calendarEvent!.name,
            "Calendar": self.calendarEvent!.calendar.name,
            "Id": self.calendarEvent!.id
        ])
        #endif
    }
    
    func addEvent() {
        guard EKEventStore.authorizationStatus(for: EKEntityType.event) != EKAuthorizationStatus.denied else {
            let alert = UIAlertView(title: "Calendar Access Denied", message: "It looks like you’ve previously chosen not to allow this app to access your calendar. You can change that in Settings.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Settings")
            alert.show()
            return
        }
        
        self.eventStore.requestAccess(to: EKEntityType.event) { granted, error in
            if (error != nil) {
                let alert = UIAlertView(title: "Error Accessing Calendar", message: "Hmm. There was a problem accessing your calendar. Sorry!", delegate: nil, cancelButtonTitle: "Cancel")
                alert.show()
            } else if (granted) {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = self.calendarEvent!.name
                event.startDate = self.calendarEvent!.from as Date
                event.endDate = self.calendarEvent!.to as Date
                event.location = self.calendarEvent!.location
                event.isAllDay = self.calendarEvent!.allDay
                self.ekEvent = event
                let eventViewController = EKEventEditViewController()
                eventViewController.eventStore = self.eventStore
                eventViewController.event = event
                eventViewController.editViewDelegate = self
                DispatchQueue.main.async {
                    self.present(eventViewController, animated: true, completion: nil)
                }
            } 
        }
    }
    
    func viewEvent(_ event: EKEvent) {
        let timestamp = event.startDate.timeIntervalSinceReferenceDate
        UIApplication.shared.openURL(URL(string: "calshow:\(timestamp)")!)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        if (action == EKEventEditViewAction.saved) {
            let alert = UIAlertView(title: "Event Saved", message: "\(self.calendarEvent!.name) has been saved to your calendar.", delegate: nil, cancelButtonTitle: "Close")
            alert.show()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let event = self.ekEvent {
            self.viewEvent(event)
        } else {
            self.addEvent()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tryMatchingEvent() {
        guard let calendarEvent = self.calendarEvent else {
            self.ekEvent = nil
            return
        }
        
        let predicate = self.eventStore.predicateForEvents(withStart: calendarEvent.from as Date, end: calendarEvent.to as Date, calendars: nil)
        self.eventStore.enumerateEvents(matching: predicate) { (event, stop) -> Void in
            if (event.title == calendarEvent.name) {
                stop.initialize(to: true)
                self.ekEvent = event
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addToCalendarEmbed") {
            let controller = segue.destination as! UITableViewController
            let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
            self.eventButtonLabel = cell.textLabel
            controller.tableView.delegate = self
        }
    }
    
    // MARK - UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex == 1) {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }
    
}
