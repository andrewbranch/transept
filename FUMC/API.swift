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
    
    private let dateFormatter = NSDateFormatter()
    #if DEBUG
    private let base = "https://fumcdev.herokuapp.com/api"
    #else
    private let base = "https://fumc.herokuapp.com/api"
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
        self.dateFormatter.dateFormat = "MM.dd.yyyy"
        let page = 1
        let from = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page - 1)))
        let to = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page)))
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
                
                let dateFormatter = NSDateFormatter()
                for calendar in calendars {
                    if let events = eventDictionaries[calendar.id] as? [NSDictionary] {
                        calendar.events = events.map { CalendarEvent(jsonDictionary: $0, calendar: calendar, dateFormatter: dateFormatter) }
                    } else {
                        calendar.events.removeAll(keepCapacity: false)
                    }
                }
                
                completed(calendars: calendars, error: nil)
            }
        }
    }
    
    func getBulletins(completed: (bulletins: [Bulletin], error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/bulletins?visible=true&orderBy=date:Z,service:A")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(bulletins: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response])
                completed(bulletins: [], error: error)
            } else {
                var error: NSError?
                var bulletinsDictionary: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]
                if (error != nil) {
                    completed(bulletins: [], error: error)
                    return
                }
                
                var bulletins = [Bulletin]()
                for json in bulletinsDictionary {
                    
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    var date = self.dateFormatter.dateFromString(json["date"] as! String)
                    
                    var b = Bulletin()
                    b.setValuesForKeysWithDictionary(json as [NSObject : AnyObject])
                    b.date = date!
                    
                    bulletins.append(b)
                }

                completed(bulletins: bulletins, error: nil)
            }
        }
    }
    
    func getWitnesses(completed: (witnesses: [Witness], error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/witnesses?visible=true&orderBy=volume:Z,issue:Z")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(witnesses: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response])
                completed(witnesses: [], error: error)
            } else {
                var error: NSError?
                var witnessesDictionary: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]
                if (error != nil) {
                    completed(witnesses: [], error: error)
                    return
                }
                
                var witnesses = [Witness]()
                for json in witnessesDictionary {
                    
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let from = self.dateFormatter.dateFromString(json["from"] as! String)
                    let to = self.dateFormatter.dateFromString(json["to"] as! String)
                    
                    var w = Witness()
                    w.setValuesForKeysWithDictionary(json as [NSObject : AnyObject])
                    w.from = from!
                    w.to = to!
                    
                    witnesses.append(w)
                }
                
                completed(witnesses: witnesses, error: nil)
            }
        }
    }
    
    func getNotifications(tester: Bool, completed: (notifications: [Notification], error: NSError?) -> Void) {
        let url = tester ? NSURL(string: "\(base)/notifications/current?tester=true") : NSURL(string: "\(base)/notifications/current")
        var request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(notifications: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response])
                completed(notifications: [], error: error)
            } else {
                var error: NSError?
                var notificationsDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as! [NSDictionary]
                if (error != nil) {
                    completed(notifications: [], error: error)
                }

                var notifications = [Notification]()
                for json in notificationsDictionaries {
                    
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    let sendDate = self.dateFormatter.dateFromString(json["sendDate"] as! String)
                    let expirationDate = self.dateFormatter.dateFromString(json["expirationDate"] as! String)
                    
                    var n = Notification()
                    n.id = json["id"] as! Int
                    n.message = json["message"] as! String
                    if let url = json["url"] as? String {
                        n.url = url
                    }
                    n.sendDate = sendDate!
                    n.expirationDate = expirationDate!
                    
                    notifications.append(n)
                }
                
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
    
    func getFeaturedContent(deviceKey: String, completed: (image: UIImage?, id: Int?, url: NSURL?, error: NSError?) -> Void) {
        let url = NSURL(string: "\(base)/features?active=true")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if (error != nil) {
                completed(image: nil, id: nil, url: nil, error: error)
            } else if (data.length == 0 || (response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! NSHTTPURLResponse)])
                completed(image: nil, id: nil, url: nil, error: error)
            } else {
                var error: NSError?
                let jsonDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &error) as! [NSDictionary]
                if (error != nil) {
                    completed(image: nil, id: nil, url: nil, error: error)
                } else if (jsonDictionaries.count > 0) {
                
                    // Doesn't work in simulator
                    
                    if let key = jsonDictionaries[0][deviceKey] as? String {
                        self.getFile(key) { data, error in
                            if (error != nil) {
                                completed(image: nil, id: nil, url: nil, error: error)
                                return
                            }
                            
                            let image = UIImage(data: data)
                            if let img = image {
                                var url: NSURL?
                                if let urlString = jsonDictionaries[0]["url"] as? String {
                                    url = NSURL(string: urlString)
                                }
                                completed(image: img, id: jsonDictionaries[0]["id"] as! Int?, url: url, error: nil)
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
