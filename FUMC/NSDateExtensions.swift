//
//  DateExtensions.swift
//  FUMC
//
//  Created by Andrew Branch on 12/6/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

public extension NSDate {
    
    func midnight() -> NSDate {
        return NSCalendar.currentCalendar().dateFromComponents(NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self))!
    }
    
    public func dayOfWeek() -> Int {
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: self).weekday
    }
    
    public func dayOfWorkWeek() -> Int {
        let weekday = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: self).weekday
        return weekday == 1 ? 7 : weekday - 1
    }
    
    func hour() -> Int {
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Hour, fromDate: self).hour
    }
    
    func minute() -> Int {
        return NSCalendar.currentCalendar().components(NSCalendarUnit.Minute, fromDate: self).minute
    }
}

public func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}