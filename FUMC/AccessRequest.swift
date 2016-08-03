//
//  AccessRequest.swift
//  FUMC
//
//  Created by Andrew Branch on 5/29/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import SwiftMoment

struct AccessRequest : Deserializable {
    enum Status: String {
        case Pending = "pending"
        case Approved = "approved"
        case Rejected = "rejected"
    }
    
    var dateRequested: NSDate?
    var dateSettled: NSDate?
    var status: Status!
    var scopes: [API.Scopes]!
    var user: User!
    
    init(rawJSON: NSData) throws {
        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments)
        let accessRequest = jsonDictionary["accessRequest"] as! NSDictionary
        dateRequested = moment(accessRequest["dateRequested"] as? String ?? "")?.date
        dateSettled = moment(accessRequest["dateSettled"] as? String ?? "")?.date
        status = Status(rawValue: accessRequest["status"] as! String)
        scopes = (accessRequest["scopes"] as! [String]).flatMap { API.Scopes(rawValue: $0) }
        user = try User(jsonDictionary: jsonDictionary["user"] as! NSDictionary)
    }
}
