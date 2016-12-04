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
import SwiftMoment
import RealmSwift

public struct Result<T> {
    let value: () throws -> T
}

public protocol Deserializable {
    init(rawJSON: Data) throws
    static func mapInit(rawJSON: Data) throws -> [Self]
}

open class API: NSObject {
    
    static let ERROR_DOMAIN = "com.fumcpensacola.transept"
    static let BAD_RESPONSE_MESSAGE = "Looks like we’re having some server troubles right now. We’re looking into it!"
    
    public enum Scopes: String {
        case DirectoryFullReadAccess = "directory_full_read_access"
    }
    
    public enum Error: Swift.Error {
        case unauthenticated
        case unauthorized
        case unknown(userMessage: String?, developerMessage: String?, userInfo: [AnyHashable: Any]?)
    }
    
    fileprivate class var instance: API {
        struct Static {
            static let instance = API()
        }
        return Static.instance
    }
    
    class func shared() -> API {
        return instance
    }
    
    fileprivate let lock = NSLock()
    fileprivate let dateFormatter = DateFormatter()
    #if DEBUG   
    public var base = "http://localhost:3000/v3"
    #else
    fileprivate let base = "https://api.fumcpensacola.com/v3"
    #endif
    
    fileprivate var _accessToken: AccessToken? = nil
    var accessToken: AccessToken? {
        get {
            return _accessToken
        }
        set(value) {
            if let token = value {
                _accessToken = token
                do {
                    try Locksmith.updateData(data: ["rawJSON": token.rawJSON], forUserAccount: "accessToken")
                } catch { }
            }
        }
    }
    
    var hasAccessToken: Bool {
        return self.accessToken != nil
    }
    
    static var lastDirectorySync: Date? {
        if let lastSyncDateString = UserDefaults.standard.string(forKey: "lastDirectorySyncDate") {
            return moment(lastSyncDateString)?.date
        }
        
        return nil;
    }
    
    override init() {
        super.init()
        if let keychainToken = Locksmith.loadDataForUserAccount(userAccount: "accessToken") {
            // self._accessToken = try? AccessToken(rawJSON: keychainToken["rawJSON"] as! NSData)
            // TODO refresh token
        }
    }
    
    func getCalendars(_ completed: @escaping (_ calendars: [Calendar], _ error: Swift.Error?) -> Void) {
        let url = URL(string: "\(base)/calendars")
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
            if (error != nil) {
                completed([], error)
            } else if ((response as! HTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! HTTPURLResponse])
                completed([], error)
            } else {
                do {
                    let calendarDictionary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    completed((calendarDictionary["data"] as! [NSDictionary]).map { Calendar(jsonDictionary: $0) }, nil)
                } catch let error {
                    completed([], error)
                }
            }
        }
    }
    
    func getEventsForCalendars(_ calendars: [Calendar], completed: @escaping (_ calendars: [Calendar], _ error: Swift.Error?) -> Void) {
        let page = 1
        self.lock.lock()
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        let start = dateFormatter.string(from: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page - 1)))
        let end = dateFormatter.string(from: Date(timeIntervalSinceNow: 60 * 60 * 24 * 7 * Double(page)))
        self.lock.unlock()
        
        let calendarIdQuery = (calendars.map { c in
            return "&filter[simple][$or][\(calendars.index(of: c)!)][calendar]=\(c.id)"
        }).joined(separator: "")
        let url = URL(string: "\(self.base)/events?filter[simple][start][$gte]=\(start)&filter[simple][end][$lte]=\(end)\(calendarIdQuery)")
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
            if (error != nil) {
                completed(calendars, error)
            } else if ((response as! HTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": response as! HTTPURLResponse])
                completed(calendars, error)
            } else {
                do {
                    let eventsDictionary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
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
                    completed(calendars, nil)
                } catch let error {
                    completed(calendars, error)
                }
            }
        }
    }
    
    func getBulletins(_ completed: @escaping (_ bulletins: [Bulletin], _ error: Swift.Error?) -> Void) {
        let url = URL(string: "\(base)/bulletins?filter[simple][visible]=true&sort=-date,%2Bservice")
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
            if (error != nil) {
                completed([], error)
            } else if ((response as! HTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response as! HTTPURLResponse])
                completed([], error)
            } else {
                do {
                    let bulletinsDictionary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                    var bulletins = [Bulletin]()
                    self.lock.lock()
                    for json in (bulletinsDictionary["data"] as! [NSDictionary]) {
                        if let b = try? Bulletin(jsonDictionary: json, dateFormatter: self.dateFormatter) {
                            bulletins.append(b)
                        }
                    }
                    self.lock.unlock()
                    
                    completed(bulletins, nil)
                } catch let error {
                    completed([], error)
                }
            }
        }
    }
    
    func getWitnesses(_ completed: @escaping (_ witnesses: [Witness], _ error: Swift.Error?) -> Void) {
        let url = URL(string: "\(base)/witnesses?filter[simple][visible]=true&sort=-volume,-issue")
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
            if (error != nil) {
                completed([], error)
            } else if ((response as! HTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response as! HTTPURLResponse])
                completed([], error)
            } else {
                do {
                    let witnessesDictionary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    var witnesses = [Witness]()
                    
                    self.lock.lock()
                    for json in (witnessesDictionary["data"] as! [NSDictionary]) {
                        let w = Witness(jsonDictionary: json, dateFormatter: self.dateFormatter)
                        witnesses.append(w)
                    }
                    self.lock.unlock()
                    
                    completed(witnesses, nil)
                } catch let error {
                    completed([], error)
                }
            }
        }
    }
    
    func getVideos(_ completed: @escaping (_ albums: [VideoAlbum], _ error: Swift.Error?) -> Void) {
        let url = URL(string: "\(base)/video-albums?filter[simple][visible]=true&include=videos&sort=-featured")
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, error in
            guard error == nil else {
                completed([], error)
                return
            }
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                completed([], NSError(domain: "NSURLDomainError", code: 0, userInfo: ["response": response as! HTTPURLResponse]))
                return
            }
            
            do {
                let videoAlbumsDictionary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                var videoAlbums = [VideoAlbum]()
                self.lock.lock()
                for json in (videoAlbumsDictionary["data"] as! [NSDictionary]) {
                    let a = VideoAlbum(jsonDictionary: json, dateFormatter: self.dateFormatter, included: videoAlbumsDictionary["included"] as? [NSDictionary])
                    videoAlbums.append(a)
                }
                self.lock.unlock()
                completed(videoAlbums, nil)
            } catch let error {
                completed([], error)
            }
            
        }
    }
    
    func getFile(_ key: String, completed: @escaping (_ data: Data, _ error: Swift.Error?) -> Void) {
        let url = self.fileURL(key: key)
        let request = URLRequest(url: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { response, data, error in
            if (error != nil) {
                completed(Data(), error)
            } else if (data!.count == 0 || (response as! HTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! HTTPURLResponse)])
                completed(Data(), error)
            } else {
                completed(data!, nil)
            }
        }
    }
    
    func sendPrayerRequest(_ text: String, completed: @escaping (_ error: NSError?) -> Void) {
        let url = URL(string: "\(base)/emailer/send")
        let request = NSMutableURLRequest(url: url!)
        let data = "{\"email\": \"\(text)\"}".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        request.httpBody = data!
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data!.count)", forHTTPHeaderField: "Content-Length")
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { response, data, error in
            if (error != nil) {
                completed(error as NSError?)
            } else if ((response as! HTTPURLResponse).statusCode != 200) {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: ["response": (response as! HTTPURLResponse)])
                completed(error)
                return
            }
            completed(nil)
        }
        
    }
    
    func fileURL(key: String) -> URL? {
         return URL(string: "\(base)/file/\(key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)")
    }
    
    fileprivate func setDigitsHeaders(request: NSMutableURLRequest, digitsSession: DGTSession) {
        let digits = Digits.sharedInstance()
        let oauthSigning = DGTOAuthSigning(authConfig: digits.authConfig, authSession: digitsSession)
        let authHeaders = oauthSigning?.oAuthEchoHeadersToVerifyCredentials() as! [String : AnyObject]
        request.setValue(Env.get("DIGITS_CONSUMER_KEY"), forHTTPHeaderField: "oauth_consumer_key")
        request.setValue(authHeaders["X-Auth-Service-Provider"] as! String!, forHTTPHeaderField: "X-Auth-Service-Provider")
        request.setValue(authHeaders["X-Verify-Credentials-Authorization"] as! String!, forHTTPHeaderField: "X-Verify-Credentials-Authorization")
    }
    
    func getAuthToken(_ session: DGTSession, scopes: [Scopes], completed: @escaping (_ token: Result<AccessToken>) -> Void) {
        let url = URL(string: "\(base)/authenticate/digits")
        let request = NSMutableURLRequest(url: url!)
        let data = try! JSONSerialization.data(withJSONObject: [ "scopes": scopes.map { $0.rawValue } ], options: JSONSerialization.WritingOptions(rawValue: 0))
        setDigitsHeaders(request: request, digitsSession: session)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        getObject(request: request, authenticated: false) { accessToken in
            completed(accessToken)
        }
    }
    
    func requestAccess(_ session: DGTSession, scopes: [Scopes], completed: @escaping (_ accessRequest: Result<AccessRequest>) -> Void) {
        let url = URL(string: "\(base)/authenticate/digits/request")
        let request = NSMutableURLRequest(url: url!)
        let data = try! JSONSerialization.data(withJSONObject: [
            "scopes": scopes.map { $0.rawValue }
        ], options: JSONSerialization.WritingOptions(rawValue: 0))
        
        setDigitsHeaders(request: request, digitsSession: session)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        getObject(request: request, authenticated: false) { accessRequest in
            completed(accessRequest)
        }
    }
    
    func updateAccessRequest(_ accessRequest: AccessRequest, session: DGTSession, facebookToken: String, completed: @escaping (_ accessRequest: Result<AccessRequest>) -> Void) {
        let url = URL(string: "\(base)/authenticate/digits/request/\(accessRequest.id!)")
        let request = NSMutableURLRequest(url: url!)
        let data = try! JSONSerialization.data(withJSONObject: [
            "facebookToken": facebookToken
        ], options: JSONSerialization.WritingOptions(rawValue: 0))
        
        setDigitsHeaders(request: request, digitsSession: session)
        request.httpMethod = "PATCH"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        getObject(request: request, authenticated: false) { updatedAccessRequest in
            completed(updatedAccessRequest)
        }
    }
    
    func revoke(reason: String?, completed: @escaping (_ result: Result<Void>) -> Void) {
        let url = URL(string: "\(base)/authenticate/digits/revoke")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        if let reason = reason {
            let data = try! JSONSerialization.data(withJSONObject: [
                "reason": reason
            ], options: JSONSerialization.WritingOptions(rawValue: 0))
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        }

        send(request: request, authenticated: true) { _ in
            completed(Result { })
        }
    }
    
    func getAccessRequest(_ id: String, session: DGTSession, completed: @escaping (_ accessRequest: Result<AccessRequest>) -> Void) {
        let url = URL(string: "\(base)/authenticate/digits/request/\(id)")
        let request = NSMutableURLRequest(url: url!)
        setDigitsHeaders(request: request, digitsSession: session)
        getObject(request: request, authenticated: false) { accessRequest in
            completed(accessRequest)
        }
    }
    
    func getMembers(_ since: Date? = lastDirectorySync, completed: ((_ result: Result<[Member]>) -> Void)? = nil) {
        let url = URL(string: "\(base)/directory/members")
        let request = NSMutableURLRequest(url: url!)
        getArray(request: request, authenticated: true) { (members: Result<[Member]>) in
            completed?(Result {
                let members = try members.value()
                let realm = try Realm()
                try realm.write {
                    members.forEach {
                        realm.add($0, update: true)
                    }
                }

                return members
            })
        }
    }
    
    fileprivate func deserializeObject<TObject: Deserializable>(_ data: Data) throws -> TObject {
        return try TObject(rawJSON: data)
    }
    
    fileprivate func deserializeArray<TObject: Deserializable>(_ data: Data) throws -> [TObject] {
        return try TObject.mapInit(rawJSON: data)
    }
    
    fileprivate func getObject<TObject: Deserializable>(request: NSMutableURLRequest, authenticated: Bool, completed: @escaping (_ result: Result<TObject>) -> Void) {
        send(request: request, authenticated: authenticated) { result in
            completed(Result {
                let res = try result.value()
                guard let data = res.data else {
                    throw Error.unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "No response body was present", userInfo: ["response": res.response])
                }
                guard let object = try? TObject(rawJSON: data) else {
                    throw Error.unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "Could not deserialize response into \(String(describing: TObject.self))", userInfo: ["rawJSON": data])
                }

                return object
            })
        }
    }
    
    fileprivate func getArray<TObject: Deserializable>(request: NSMutableURLRequest, authenticated: Bool, completed: @escaping (_ result: Result<[TObject]>) -> Void) {
        send(request: request, authenticated: authenticated) { result in
            completed(Result {
                let res = try result.value()
                guard let data = res.data else {
                    throw Error.unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "No response body was present", userInfo: ["response": res.response])
                }
                guard let array = try? TObject.mapInit(rawJSON: data) else {
                    throw Error.unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "Could not deserialize response into array of \(String(describing: TObject.self))", userInfo: ["rawJSON": data])
                }
                
                return array
            })
        }
    }

    fileprivate func send(request: NSMutableURLRequest, authenticated: Bool, completed: @escaping (_ result: Result<(response: HTTPURLResponse, data: Data?)>) -> Void) {
        if (authenticated) {
            guard let token = accessToken else {
                return completed(Result {
                    throw API.Error.unauthenticated
                    })
            }
            
            request.setValue("Bearer \(token.signed)", forHTTPHeaderField: "Authorization")
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) { response, data, error in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard error == nil else {
                return completed(Result { throw error! })
            }
            let response = response as! HTTPURLResponse
            guard response.statusCode != 401 else {
                return completed(Result { throw Error.unauthenticated })
            }
            guard response.statusCode != 403 else {
                return completed(Result { throw Error.unauthorized })
            }
            guard response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204 else {
                return completed(Result {
                    throw Error.unknown(userMessage: API.BAD_RESPONSE_MESSAGE, developerMessage: "Status code was \(response.statusCode)", userInfo: ["response": response])
                })
            }
            
            completed(Result { (response, data) })
        }
    }
   
}
