//
//  ArrayExtensions.swift
//  FUMC
//
//  Created by Andrew Branch on 10/4/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import UIKit

/**
Remove an element from the array
*/
public func - <T: Equatable> (first: [T], second: T) -> [T] {
    return first - [second]
}

/**
Difference operator
*/
public func - <T: Equatable> (first: [T], second: [T]) -> [T] {
    return first.difference(second)
}

public extension Collection where Iterator.Element : Equatable {
    public func has(_ x: Self.Iterator.Element) -> Bool {
        return self.index(of: x) != nil
    }
}

public extension Array {
    public func find(_ condition: (Element) -> Bool) -> Element? {
        for element in self {
            if condition(element) {
                return element
            }
        }
        return nil
    }
    
    /**
    Iterates on each element of the array.
    
    :param: call Function to call for each element
    */
    func each (_ call: (Element) -> ()) {
        
        for item in self {
            call(item)
        }
        
    }
    
    /**
    Difference of self and the input arrays.
    
    :param: values Arrays to subtract
    :returns: Difference of self and the input arrays
    */
    func difference <T: Equatable> (_ values: [T]...) -> [T] {
        
        var result = [T]()
        
        elements: for e in self {
            if let element = e as? T {
                for value in values {
                    //  if a value is in both self and one of the values arrays
                    //  jump to the next iteration of the outer loop
                    if value.contains(element) {
                        continue elements
                    }
                }
                
                //  element it's only in self
                result.append(element)
            }
        }
        
        return result
        
    }
}

public extension Dictionary {
    func has (_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    /**
    Constructs a dictionary containing every [key: value] pair from self
    for which testFunction evaluates to true.
    
    :param: testFunction Function called to test each key, value
    :returns: Filtered dictionary
    */
    func filteredDictionary (_ test: (Key, Value) -> Bool) -> Dictionary {
        
        var result = Dictionary()
        
        for (key, value) in self {
            if test(key, value) {
                result[key] = value
            }
        }
        
        return result
        
    }
    
    /**
    Loops trough each [key: value] pair in self.
    
    :param: eachFunction Function to inovke on each loop
    */
    func each (_ each: (Key, Value) -> ()) {
        
        for (key, value) in self {
            each(key, value)
        }
        
    }
    
    /**
    Union of self and the input dictionaries.
    
    :param: dictionaries Dictionaries to join
    :returns: Union of self and the input dictionaries
    */
    func union (_ dictionaries: Dictionary...) -> Dictionary {
        
        var result = self
        
        dictionaries.each { (dictionary) -> Void in
            dictionary.each { (key, value) -> Void in
                _ = result.updateValue(value, forKey: key)
            }
        }
        
        return result
        
    }
}

public func < (lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}

public func > (lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}

public func - (lhs: Date, rhs: Date) -> TimeInterval {
    return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
}

public extension Date {
    // MARK: Getter
    
    /**
    Date year
    */
    public var year : Int {
        get {
            return getComponent(.year)
        }
    }
    
    /**
    Date month
    */
    public var month : Int {
        get {
            return getComponent(.month)
        }
    }
    
    /**
    Date weekday
    */
    public var weekday : Int {
        get {
            return getComponent(.weekday)
        }
    }
    
    /**
    Date weekMonth
    */
    public var weekMonth : Int {
        get {
            return getComponent(.weekOfMonth)
        }
    }
    
    
    /**
    Date days
    */
    public var days : Int {
        get {
            return getComponent(.day)
        }
    }
    
    /**
    Date hours
    */
    public var hours : Int {
        
        get {
            return getComponent(.hour)
        }
    }
    
    /**
    Date minuts
    */
    public var minutes : Int {
        get {
            return getComponent(.minute)
        }
    }
    
    /**
    Date seconds
    */
    public var seconds : Int {
        get {
            return getComponent(.second)
        }
    }
    
    /**
    Returns the value of the NSDate component
    
    :param: component NSCalendarUnit
    :returns: the value of the component
    */
    
    public func getComponent (_ component : NSCalendar.Unit) -> Int {
        let calendar = Foundation.Calendar.current
        let components = (calendar as NSCalendar).components(component, from: self)
        
        return components.value(for: component)
    }
}
