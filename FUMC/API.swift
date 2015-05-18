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
    private let base = "http://api.fumcpensacola.com/v2"
    #else
    private let base = "http://api.fumcpensacola.com/v2"
    #endif
    
    func getCalendars(completed: (calendars: [Calendar], error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/calendars")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(calendars: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(calendars: [], error: error)
            } else {
                var error: NSError?
                let calendarDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                if (error != nil) {
                    completed(calendars: [], error: error)
                    return
                }
                
                completed(calendars: (calendarDictionary["data"] as! [NSDictionary]).map { Calendar(jsonDictionary: $0) }, error: nil)
            }
        }
    }
    
    func getEventsForCalendars(calendars: [Calendar], completed: (calendars: [Calendar], error: NSError?) -> Void) {
        let page = 1
        self.lock.lock()
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        let start = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page - 1)))
        let end = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page)))
        self.lock.unlock()
        
        let calendarIdQuery = "".join(calendars.map { c in
            return "&filter[simple][$or][\(calendars.indexOf(c)!)][calendar]=\(c.id)"
        })
        let url = NSURL(string: "\(self.base)/events?filter[simple][start][$gte]=\(start)&filter[simple][end][$lte]=\(end)\(calendarIdQuery)")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(calendars: calendars, error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(calendars: calendars, error: error)
            } else {
                var error: NSError?
                let eventsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
                if (error != nil) {
                    return completed(calendars: calendars, error: error)
                }
                
                let events = eventsDictionary["data"] as! [NSDictionary]
                self.lock.lock()
                for c in calendars {
                    c.events = events.filter {
                        return c.id == ((($0["links"] as! NSDictionary)["calendar"] as! NSDictionary)["linkage"] as! NSDictionary)["id"] as! String
                    }.map {
                        return CalendarEvent(jsonDictionary: $0, calendar: c, dateFormatter: self.dateFormatter)
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
