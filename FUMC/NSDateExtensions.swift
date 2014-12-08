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
}

func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}

func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}