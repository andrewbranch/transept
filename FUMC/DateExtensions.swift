//
//  DateExtensions.swift
//  FUMC
//
//  Created by Andrew Branch on 12/6/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

public extension Date {
    
    func midnight() -> Date {
        return Foundation.Calendar.current.date(from: (Foundation.Calendar.current as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: self))!
    }
    
    public func dayOfWeek() -> Int {
        return (Foundation.Calendar.current as NSCalendar).components(NSCalendar.Unit.weekday, from: self).weekday!
    }
    
    public func dayOfWorkWeek() -> Int {
        let weekday = (Foundation.Calendar.current as NSCalendar).components(NSCalendar.Unit.weekday, from: self).weekday
        return weekday! == 1 ? 7 : weekday! - 1
    }
    
    func hour() -> Int {
        return (Foundation.Calendar.current as NSCalendar).components(NSCalendar.Unit.hour, from: self).hour!
    }
    
    func minute() -> Int {
        return (Foundation.Calendar.current as NSCalendar).components(NSCalendar.Unit.minute, from: self).minute!
    }
    
    public var year: Int {
        return (Foundation.Calendar.current as NSCalendar).components(NSCalendar.Unit.year, from: self).year!
    }
}
