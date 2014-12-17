//
//  DateExtensions.swift
//  FUMC
//
//  Created by Andrew Branch on 12/6/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

extension NSDate {
    
    func midnight() -> NSDate {
        return NSCalendar.currentCalendar().dateFromComponents(NSCalendar.currentCalendar().components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: self))!
    }
    
    func year() -> Int {
        return NSCalendar.currentCalendar().components(.YearCalendarUnit, fromDate: self).year
    }
    
    func dayOfWeek() -> Int {
        return NSCalendar.currentCalendar().components(.WeekdayCalendarUnit, fromDate: self).weekday
    }
    
    func dayOfWorkWeek() -> Int {
        let weekday = NSCalendar.currentCalendar().components(.WeekdayCalendarUnit, fromDate: self).weekday
        return weekday == 0 ? 6 : weekday - 1
    }
    
    func hour() -> Int {
        return NSCalendar.currentCalendar().components(.HourCalendarUnit, fromDate: self).hour
    }
    
    func minute() -> Int {
        return NSCalendar.currentCalendar().components(.MinuteCalendarUnit, fromDate: self).minute
    }
}

func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}

func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}

func - (lhs: NSDate, rhs: NSDate) -> NSTimeInterval {
    return lhs.timeIntervalSinceDate(rhs)
}