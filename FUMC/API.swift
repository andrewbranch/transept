//
//  API.swift
//  FUMC
//
//  Created by Andrew Branch on 12/11/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import Foundation
import UIKit
import DigitsKit
import Locksmith

public struct Result<T> {
    let value: () throws -> T
}

public protocol Deserializable {
    init(rawJSON: NSData) throws
}

public class API: NSObject {
    
    static let ERROR_DOMAIN = "com.fumcpensacola.transept"
    static let BAD_RESPONSE_MESSAGE = "Looks like we’re having some server troubles right now. We’re looking into it!"
    
    public enum Scopes: String {
        case DirectoryFullReadAccess = "directory_full_read_access"
    }
    
    public enum Error: ErrorType {
        case Unauthenticated
        case Unauthorized
        case Unknown(userMessage: String?, developerMessage: String?, userInfo: [NSObject: AnyObject]?)
    }
    
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
    private let base = "http://localhost:3000/v3"
    #else
    private let base = "https://api.fumcpensacola.com/v3"
    #endif
    
    private var _accessToken: AccessToken? = nil
    var accessToken: AccessToken? {
        get {
            return _accessToken
        }
        set(value) {
            if let token = value {
                do {
                    try Locksmith.updateData(["rawJSON": token.rawJSON], forUserAccount: "accessToken")
                } catch { }
            }
        }
    }
    
    var hasAccessToken: Bool {
        return self.accessToken != nil
    }
    
    override init() {
        super.init()
        if let keychainToken = Locksmith.loadDataForUserAccount("accessToken") {
//            self._accessToken = try? AccessToken(rawJSON: keychainToken["rawJSON"] as! NSData)
            // TODO refresh token
        }
    }
    
    func getCalendars(completed: (calendars: [Calendar], error: ErrorType?) -> Void) {
        let url = NSURL(string: "\(base)/calendars")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(calendars: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(calendars: [], error: error)
            } else {
                do {
                    let calendarDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    completed(calendars: (calendarDictionary["data"] as! [NSDictionary]).map { Calendar(jsonDictionary: $0) }, error: nil)
                } catch let error {
                    completed(calendars: [], error: error)
                }
            }
        }
    }
    
    func getEventsForCalendars(calendars: [Calendar], completed: (calendars: [Calendar], error: ErrorType?) -> Void) {
        let page = 1
        self.lock.lock()
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        let start = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page - 1)))
        let end = dateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page)))
        self.lock.unlock()
        
        let calendarIdQuery = (calendars.map { c in
            return "&filter[simple][$or][\(calendars.indexOf(c)!)][calendar]=\(c.id)"
        }).joinWithSeparator("")
        let url = NSURL(string: "\(self.base)/events?filter[simple][start][$gte]=\(start)&filter[simple][end][$lte]=\(end)\(calendarIdQuery)")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(calendars: calendars, error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(calendars: calendars, error: error)
            } else {
                do {
                    let eventsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let events = eventsDictionary["data"] as! [NSDictionary]
                    self.lock.lock()
                    for c in calendars {
                        c.events = events.filter {
                            return c.id == ((($0["relationships"] as! NSDictionary)["calendar"] as! NSDictionary)["data"] as! NSDictionary)["id"] as! String
                        }.map {
                            return CalendarEvent(jsonDictionary: $0, calendar: c, dateFormatter: self.dateFormatter)
                        }
                    }
                    self.lock.unlock()
                    completed(calendars: calendars, error: nil)
                } catch let error {
                    completed(calendars: calendars, error: error)
                }
            }
        }
    }
    
    func getBulletins(completed: (bulletins: [Bulletin], error: ErrorType?) -> Void) {
        let url = NSURL(string: "\(base)/bulletins?filter[simple][visible]=true&sort=-date,%2Bservice")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(bulletins: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(bulletins: [], error: error)
            } else {
                do {
                    let bulletinsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                    var bulletins = [Bulletin]()
                    self.lock.lock()
                    for json in (bulletinsDictionary["data"] as! [NSDictionary]) {
                        if let b = try? Bulletin(jsonDictionary: json, dateFormatter: self.dateFormatter) {
                            bulletins.append(b)
                        }
                    }
                    self.lock.unlock()
                    
                    completed(bulletins: bulletins, error: nil)
                } catch let error {
                    completed(bulletins: [], error: error)
                }
            }
        }
    }
    
    func getWitnesses(completed: (witnesses: [Witness], error: ErrorType?) -> Void) {
        let url = NSURL(string: "\(base)/witnesses?filter[simple][visible]=true&sort=-volume,-issue")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil) {
                completed(witnesses: [], error: error)
            } else if ((response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response as! NSHTTPURLResponse])
                completed(witnesses: [], error: error)
            } else {
                do {
                    let witnessesDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    var witnesses = [Witness]()
                    
                    self.lock.lock()
                    for json in (witnessesDictionary["data"] as! [NSDictionary]) {
                        let w = Witness(jsonDictionary: json, dateFormatter: self.dateFormatter)
                        witnesses.append(w)
                    }
                    self.lock.unlock()
                    
                    completed(witnesses: witnesses, error: nil)
                } catch let error {
                    completed(witnesses: [], error: error)
                }
            }
        }
    }
    
    func getVideos(completed: (albums: [VideoAlbum], error: ErrorType?) -> Void) {
        let url = NSURL(string: "\(base)/video-albums?filter[simple][visible]=true&include=videos&sort=-featured")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            guard error == nil else {
                completed(albums: [], error: error)
                return
            }
            guard (response as! NSHTTPURLResponse).statusCode == 200 else {
                completed(albums: [], error: NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response as! NSHTTPURLResponse]))
                return
            }
            
            do {
                let videoAlbumsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                var videoAlbums = [VideoAlbum]()
                self.lock.lock()
                for json in (videoAlbumsDictionary["data"] as! [NSDictionary]) {
                    let a = VideoAlbum(jsonDictionary: json, dateFormatter: self.dateFormatter, included: videoAlbumsDictionary["included"] as? [NSDictionary])
                    videoAlbums.append(a)
                }
                self.lock.unlock()
                completed(albums: videoAlbums, error: nil)
            } catch let error {
                completed(albums: [], error: error)
            }
            
        }
    }
    
    func getFile(key: String, completed: (data: NSData, error: ErrorType?) -> Void) {
        let url = self.fileURL(key: key)
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if (error != nil) {
                completed(data: NSData(), error: error)
            } else if (data!.length == 0 || (response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! NSHTTPURLResponse)])
                completed(data: NSData(), error: error)
            } else {
                completed(data: data!, error: nil)
            }
        }
    }
    
    func getFeaturedContent(deviceKey: String, completed: (image: UIImage?, id: String?, url: NSURL?, error: ErrorType?) -> Void) {
        let url = NSURL(string: "\(base)/features?filter[simple][active]=true")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            if (error != nil) {
                completed(image: nil, id: nil, url: nil, error: error)
            } else if (data!.length == 0 || (response as! NSHTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! NSHTTPURLResponse)])
                completed(image: nil, id: nil, url: nil, error: error)
            } else {
                do {
                    let featuresDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    if (featuresDictionary["data"]!.count > 0) {
                    
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
                                    completed(image: nil, id: nil, url: nil, error: NSError(domain: "com.fumcpensacola.transept", code: 1, userInfo: nil))
                                }
                            }
                        } else {
                            completed(image: nil, id: nil, url: nil, error: NSError(domain: "com.fumcpensacola.transept", code: 1, userInfo: nil))
                        }
                    } else {
                        completed(image: nil, id: nil, url: nil, error: NSError(domain: "com.fumcpensacola.transept", code: 1, userInfo: nil))
                    }
                } catch let error {
                    completed(image: nil, id: nil, url: nil, error: error)
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
    
    func fileURL(key key: String) -> NSURL? {
         return NSURL(string: "\(base)/file/\(key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)")
    }
    
    private func setDigitsHeaders(request request: NSMutableURLRequest, digitsSession: DGTSession) {
        let digits = Digits.sharedInstance()
        let oauthSigning = DGTOAuthSigning(authConfig: digits.authConfig, authSession: digitsSession)
        let authHeaders = oauthSigning.OAuthEchoHeadersToVerifyCredentials() as! [String : AnyObject]
        request.setValue(Env.get("DIGITS_CONSUMER_KEY"), forHTTPHeaderField: "oauth_consumer_key")
        request.setValue(authHeaders["X-Auth-Service-Provider"] as! String!, forHTTPHeaderField: "X-Auth-Service-Provider")
        request.setValue(authHeaders["X-Verify-Credentials-Authorization"] as! String!, forHTTPHeaderField: "X-Verify-Credentials-Authorization")
    }
    
    func getAuthToken(session: DGTSession, scopes: [Scopes], completed: (token: Result<AccessToken>) -> Void) throws {
        let url = NSURL(string: "\(base)/authenticate/digits")
        let request = NSMutableURLRequest(URL: url!)
        let data = try NSJSONSerialization.dataWithJSONObject([ "scopes": scopes.map { $0.rawValue } ], options: NSJSONWritingOptions(rawValue: 0))
        setDigitsHeaders(request: request, digitsSession: session)
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
        
        try sendRequest(request) { accessToken in
            completed(token: accessToken)
        }
    }
    
    func requestAccess(session: DGTSession, scopes: [Scopes], completed: (accessRequest: Result<AccessRequest>) -> Void) throws {
        let url = NSURL(string: "\(base)/authenticate/digits/request")
        let request = NSMutableURLRequest(URL: url!)
        let data = try NSJSONSerialization.dataWithJSONObject([
            "scopes": scopes.map { $0.rawValue }
        ], options: NSJSONWritingOptions(rawValue: 0))
        
        setDigitsHeaders(request: request, digitsSession: session)
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
        
        try sendRequest(request) { accessRequest in
            completed(accessRequest: accessRequest)
        }
    }
    
    func updateAccessRequest(accessRequest: AccessRequest, session: DGTSession, facebookToken: String, completed: (accessRequest: Result<AccessRequest>) -> Void) throws {
        let url = NSURL(string: "\(base)/authenticate/digits/request/\(accessRequest.id)")
        let request = NSMutableURLRequest(URL: url!)
        let data = try NSJSONSerialization.dataWithJSONObject([
            "facebookToken": facebookToken
        ], options: NSJSONWritingOptions(rawValue: 0))
        
        setDigitsHeaders(request: request, digitsSession: session)
        request.HTTPMethod = "PATCH"
        request.HTTPBody = data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
        
        try sendRequest(request) { updatedAccessRequest in
            completed(accessRequest: updatedAccessRequest)
        }
    }
    
    private func sendAuthenticatedRequest<TResponseType: Deserializable>(request: NSMutableURLRequest, completed: (result: Result<TResponseType>) -> Void) throws {
        guard let token = accessToken else {
            throw NSError(domain: API.ERROR_DOMAIN, code: 3, userInfo: ["developerMessage": "No access token present", "userMessage": AppDelegate.USER_UNKNOWN_ERROR_MESSAGE])
        }
        
        request.setValue("Authorization", forHTTPHeaderField: "Bearer \(token.signed)")
        try sendRequest(request) { result in
            completed(result: result)
        }
    }
    
    private func sendRequest<TResponseType: Deserializable>(request: NSMutableURLRequest, completed: (result: Result<TResponseType>) -> Void) throws {
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { response, data, error in
            guard error == nil else {
                return completed(result: Result { throw error! })
            }
            let response = response as! NSHTTPURLResponse
            guard response.statusCode != 401 else {
                return completed(result: Result { throw Error.Unauthenticated })
            }
            guard response.statusCode != 403 else {
                return completed(result: Result { throw Error.Unauthorized })
            }
            guard response.statusCode == 200 || response.statusCode == 204 else {
                return completed(result: Result {
                    throw Error.Unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "Status code was \(response.statusCode)", userInfo: ["response": response])
                })
            }
            guard let data = data else {
                return completed(result: Result {
                    throw Error.Unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "No response body was present", userInfo: ["response": response])
                })
            }
            guard let result = try? TResponseType(rawJSON: data) else {
                return completed(result: Result {
                    throw Error.Unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "Could not deserialize response into \(String(TResponseType))", userInfo: ["rawJSON": data])
                })
            }
            
            completed(result: Result { result })
        }
    }
   
}
