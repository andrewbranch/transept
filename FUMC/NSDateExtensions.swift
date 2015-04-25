//
//  DateExtensions.swift
//  FUMC
//
//  Created by Andrew Branch on 12/6/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

extension NSDate {
    
    func midnight() -> NSDate {
        return NSCalendar.currentCalendar().dateFromComponents(NSCalendar.currentCalendar().components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: self))!
    }
    
    func dayOfWeek() -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitWeekday, fromDate: self).weekday
    }
    
    func dayOfWorkWeek() -> Int {
        let weekday = NSCalendar.currentCalendar().components(.CalendarUnitWeekday, fromDate: self).weekday
        return weekday == 0 ? 6 : weekday - 1
    }
    
    func hour() -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: self).hour
    }
    
    func minute() -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitMinute, fromDate: self).minute
    }
}

public func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}