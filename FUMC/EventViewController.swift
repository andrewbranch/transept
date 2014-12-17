//
//  EventViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/12/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.monthLabel!.text = String(Array(self.dateFormatter.stringFromDate(self.calendarEvent!.from))[0...2]).uppercaseString
        self.dateFormatter.dateFormat = "dd"
        self.dayLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        self.titleLabel!.text = self.calendarEvent!.name
        
        self.locationLabel!.text = self.calendarEvent!.location
        self.dateFormatter.dateFormat = "EEEE, MMMM d yyyy"
        self.dateLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        
        if (self.calendarEvent!.allDay) {
            self.fromTimeLabel!.superview!.subviews.each { ($0 as UIView).hidden = true }
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
}
