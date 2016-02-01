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

public extension CollectionType where Generator.Element : Equatable {
    public func has(x: Self.Generator.Element) -> Bool {
        return self.indexOf(x) != nil
    }
}

public extension Array {
    public func find(condition: (Element) -> Bool) -> Element? {
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
    func each (call: (Element) -> ()) {
        
        for item in self {
            call(item)
        }
        
    }
    
    /**
    Difference of self and the input arrays.
    
    :param: values Arrays to subtract
    :returns: Difference of self and the input arrays
    */
    func difference <T: Equatable> (values: [T]...) -> [T] {
        
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
    func has (key: Key) -> Bool {
        return indexForKey(key) != nil
    }
    
    /**
    Constructs a dictionary containing every [key: value] pair from self
    for which testFunction evaluates to true.
    
    :param: testFunction Function called to test each key, value
    :returns: Filtered dictionary
    */
    func filteredDictionary (test: (Key, Value) -> Bool) -> Dictionary {
        
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
    func each (each: (Key, Value) -> ()) {
        
        for (key, value) in self {
            each(key, value)
        }
        
    }
    
    /**
    Union of self and the input dictionaries.
    
    :param: dictionaries Dictionaries to join
    :returns: Union of self and the input dictionaries
    */
    func union (dictionaries: Dictionary...) -> Dictionary {
        
        var result = self
        
        dictionaries.each { (dictionary) -> Void in
            dictionary.each { (key, value) -> Void in
                _ = result.updateValue(value, forKey: key)
            }
        }
        
        return result
        
    }
}

public func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
}

public func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
}

public func - (lhs: NSDate, rhs: NSDate) -> NSTimeInterval {
    return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
}

public extension NSDate {
    // MARK: Getter
    
    /**
    Date year
    */
    public var year : Int {
        get {
            return getComponent(.Year)
        }
    }
    
    /**
    Date month
    */
    public var month : Int {
        get {
            return getComponent(.Month)
        }
    }
    
    /**
    Date weekday
    */
    public var weekday : Int {
        get {
            return getComponent(.Weekday)
        }
    }
    
    /**
    Date weekMonth
    */
    public var weekMonth : Int {
        get {
            return getComponent(.WeekOfMonth)
        }
    }
    
    
    /**
    Date days
    */
    public var days : Int {
        get {
            return getComponent(.Day)
        }
    }
    
    /**
    Date hours
    */
    public var hours : Int {
        
        get {
            return getComponent(.Hour)
        }
    }
    
    /**
    Date minuts
    */
    public var minutes : Int {
        get {
            return getComponent(.Minute)
        }
    }
    
    /**
    Date seconds
    */
    public var seconds : Int {
        get {
            return getComponent(.Second)
        }
    }
    
    /**
    Returns the value of the NSDate component
    
    :param: component NSCalendarUnit
    :returns: the value of the component
    */
    
    public func getComponent (component : NSCalendarUnit) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(component, fromDate: self)
        
        return components.valueForComponent(component)
    }
}