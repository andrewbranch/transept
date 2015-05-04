//
//  API.swift
//  FUMC
//
//  Created by Andrew Branch on 12/11/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import Foundation
import UIKit

class API: NSObject {
    
    private class var instance: API {
        struct Static {
            static let instance = API()
        }
        return Static.instance
    }
    
    class func shared() -> API {
        return instance
    }
    
    private let lock = NSLock()
    private let dateFormatter = NSDateFormatter()
    #if DEBUG   
    private let base = "https://fumc.herokuapp.com/api/v2"
    #else
    private let base = "https://fumc.herokuapp.com/api/v2"
    #endif
    
    func getCalendars(completed: (calendars: [Calendar], error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/calendars/list")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(calendars: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(calendars: [], error: error)
            } else {
                var error: NSError?
                let calendarDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! [NSDictionary]
                if (error != nil) {
                    completed(calendars: [], error: error)
                    return
                }
                
                completed(calendars: calendarDictionaries.map { Calendar(jsonDictionary: $0) }, error: nil)
            }
        }
    }
    
    func getEventsForCalendars(calendars: [Calendar], completed: (calendars: [Calendar], error: NSError?) -> Void) {
        let page = 1
        self.lock.lock()
        self.dateFormatter.dateFormat = "MM.dd.yyyy"
        let from = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page - 1)))
        let to = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page)))
        self.lock.unlock()
        let ids = ",".join(calendars.map { $0.id })
        let url = NSURL(string: "\(base)/calendars/\(ids).json?from=\(from)&to=\(to)")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(calendars: calendars, error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(calendars: calendars, error: error)
            } else {
                var error: NSError?
                let eventDictionaries: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                if (error != nil) {
                    completed(calendars: calendars, error: error)
                    return
                }
                
                self.lock.lock()
                for calendar in calendars {
                    if let events = eventDictionaries[calendar.id] as? [NSDictionary] {
                        calendar.events = events.map { CalendarEvent(jsonDictionary: $0, calendar: calendar, dateFormatter: self.dateFormatter) }
                    } else {
                        calendar.events.removeAll(keepCapacity: false)
                    }
                }
                self.lock.unlock()
                completed(calendars: calendars, error: nil)
            }
        }
    }
    
    func getBulletins(completed: (bulletins: [Bulletin], error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/bulletins?filter[simple][visible]=true&sort=-date,%2Bservice")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(bulletins: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response])
                completed(bulletins: [], error: error)
            } else {
                var error: NSError?
                var bulletinsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                if (error != nil) {
                    completed(bulletins: [], error: error)
                    return
                }
                
                var bulletins = [Bulletin]()
                self.lock.lock()
                for json in (bulletinsDictionary["data"] as! [NSDictionary]) {
                    var b = Bulletin(jsonDictionary: json, dateFormatter: self.dateFormatter)
                    bulletins.append(b)
                }
                self.lock.unlock()
                
                completed(bulletins: bulletins, error: nil)
            }
        }
    }
    
    func getWitnesses(completed: (witnesses: [Witness], error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/witnesses?filter[simple][visible]=true&sort=-volume,-issue")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(witnesses: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response])
                completed(witnesses: [], error: error)
            } else {
                var error: NSError?
                var witnessesDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                if (error != nil) {
                    completed(witnesses: [], error: error)
                    return
                }
                
                var witnesses = [Witness]()
                
                self.lock.lock()
                for json in (witnessesDictionary["data"] as! [NSDictionary]) {
                    var w = Witness(jsonDictionary: json, dateFormatter: self.dateFormatter)
                    witnesses.append(w)
                }
                self.lock.unlock()
                
                completed(witnesses: witnesses, error: nil)
            }
        }
    }
    
    func getNotifications(tester: Bool, completed: (notifications: [Notification], error: NSError?) -> Void) {
        self.lock.lock()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let urlString = "\(base)/notifications?filter[simple][expirationDate][$gt]=\(self.dateFormatter.stringFromDate(NSDate()))" + (tester ? "" : "&filter[simple][test]=false")
        self.lock.unlock()
        var request = NSURLRequest(URL: NSURL(string: urlString)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(notifications: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response])
                completed(notifications: [], error: error)
            } else {
                var error: NSError?
                var notificationsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                if (error != nil) {
                    completed(notifications: [], error: error)
                }

                var notifications = [Notification]()
                self.lock.lock()
                for json in (notificationsDictionary["data"] as! [NSDictionary]) {
                    var n = Notification(jsonDictionary: json, dateFormatter: self.dateFormatter)
                    notifications.append(n)
                }
                self.lock.unlock()
                
                completed(notifications: notifications, error: nil)
            }
        }
    }
    
    func getFile(key: String, completed: (data: NSData, error: NSError?) -> Void) {
        let url = self.fileURL(key: key)
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if (error != nil) {
                completed(data: NSData(), error: error)
            } else if (data.length == 0 || (response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! NSHTTPURLResponse)])
                completed(data: NSData(), error: error)
            } else {
                completed(data: data, error: nil)
            }
        }
    }
    
    func getFeaturedContent(deviceKey: String, completed: (image: UIImage?, id: String?, url: NSURL?, error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/features?filter[simple][active]=true")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if (error != nil) {
                completed(image: nil, id: nil, url: nil, error: error)
            } else if (data.length == 0 || (response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! NSHTTPURLResponse)])
                completed(image: nil, id: nil, url: nil, error: error)
            } else {
                var error: NSError?
                let featuresDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                if (error != nil) {
                    completed(image: nil, id: nil, url: nil, error: error)
                } else if (featuresDictionary["data"]!.count > 0) {
                
                    // Doesn't work in simulator
                    
                    if let key = featuresDictionary["data"]![0][deviceKey] as? String {
                        self.getFile(key) { data, error in
                            if (error != nil) {
                                completed(image: nil, id: nil, url: nil, error: error)
                                return
                            }
                            
                            let image = UIImage(data: data)
                            if let img = image {
                                var url: NSURL?
                                if let urlString = featuresDictionary["data"]![0]["url"] as? String {
                                    url = NSURL(string: urlString)
                                }
                                completed(image: img, id: (featuresDictionary["data"]![0]["id"] as! String), url: url, error: nil)
                            } else {
                                completed(image: nil, id: nil, url: nil, error: NSError())
                            }
                        }
                    } else {
                        completed(image: nil, id: nil, url: nil, error: NSError())
                    }
                } else {
                    completed(image: nil, id: nil, url: nil, error: NSError())
                }
            }
        }
    }
    
    func sendPrayerRequest(text: String, completed: (error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/emailer/send")
        let request = NSMutableURLRequest(URL: url!)
        let data = "{\"email\": \"\(text)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        request.HTTPBody = data!
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data!.length)", forHTTPHeaderField: "Content-Length")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if (error != nil) {
                completed(error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! NSHTTPURLResponse)])
                completed(error: error)
                return
            }
            completed(error: nil)
        }
        
    }
    
    func fileURL(#key: String) -> NSURL? {
        return NSURL(string: "\(base)/file/\(key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)")
    }
   
}
