//
//  EventViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/12/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, BEMAnalogClockDelegate {
    
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet var clockView: BEMAnalogClockView?
    
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
    
    var calendarEvent: CalendarEvent?
    var dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Event Detail"
        self.navigationController!.navigationBar.setTitleVerticalPositionAdjustment(0, forBarMetrics: UIBarMetrics.Default)
        self.clockView!.delegate = self
        
        self.clockView!.hourHandColor = UIColor(white: 0.2, alpha: 1)
        self.clockView!.hourHandWidth = 2
        self.clockView!.hourHandLength = 20
        self.clockView!.hourHandOffsideLength = 7
        
        self.clockView!.minuteHandColor = UIColor.darkGrayColor()
        self.clockView!.minuteHandWidth = 1
        self.clockView!.minuteHandLength = 32
        self.clockView!.minuteHandOffsideLength = 7
        
        self.clockView!.secondHandAlpha = 0
        
        self.clockView!.faceBackgroundColor = UIColor.whiteColor()
        self.clockView!.faceBackgroundAlpha = 1
        self.clockView!.borderColor = UIColor(white: 0.2, alpha: 1)
        self.clockView!.borderWidth = 4
        
        if let font = UIFont(name: "MyriadPro-Regular", size: 14) {
            self.descriptionLabel!.font = font
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        var dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: self.calendarEvent!.from)
        self.clockView!.hours = dateComponents.hour
        self.clockView!.minutes = dateComponents.minute
        self.dateFormatter.dateFormat = "MMM"
        self.monthLabel!.text = String(Array(self.dateFormatter.stringFromDate(self.calendarEvent!.from))[0...2]).uppercaseString
        self.dateFormatter.dateFormat = "dd"
        self.dayLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        self.titleLabel!.text = self.calendarEvent!.name
        
        self.dateFormatter.dateFormat = "EEEE, MMMM d yyyy"
        if (self.calendarEvent!.location.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "") {
            self.locationLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
            self.dateLabel!.text = ""
        }
        
        self.locationLabel!.text = self.calendarEvent!.location
        self.dateLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        self.dateFormatter.dateFormat = "h:mm"
        self.fromTimeLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        self.toTimeLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.to)
        self.dateFormatter.dateFormat = "a"
        self.fromMeridiemLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.from)
        self.toMeridiemLabel!.text = self.dateFormatter.stringFromDate(self.calendarEvent!.to)
        self.descriptionLabel!.text = self.calendarEvent!.descript
    }
    
    func analogClock(clock: BEMAnalogClockView!, graduationColorForIndex index: Int) -> UIColor! {
        if (index % 15 == 0) {
            return UIColor.darkGrayColor()
        }
        return UIColor.lightGrayColor()
    }
    
    func analogClock(clock: BEMAnalogClockView!, graduationAlphaForIndex index: Int) -> CGFloat {
        if (index % 5 == 0) {
            return 1
        }
        return 0
    }
    
    func analogClock(clock: BEMAnalogClockView!, graduationLengthForIndex index: Int) -> CGFloat {
        return 5
    }
    
    func analogClock(clock: BEMAnalogClockView!, graduationWidthForIndex index: Int) -> CGFloat {
        return 0.5
    }
    
    func analogClock(clock: BEMAnalogClockView!, graduationOffsetForIndex index: Int) -> CGFloat {
        return 1
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
