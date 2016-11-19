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
    
    var id: String!
    var dateRequested: NSDate?
    var dateSettled: NSDate?
    var status: Status!
    var scopes: [API.Scopes]!
    var user: User!
    
    static func mapInit(rawJSON rawJSON: NSData) throws -> [AccessRequest] {
        fatalError("No such thing as an array response of access requests")
    }
    
    init(rawJSON: NSData) throws {
        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments)
        let accessRequest = jsonDictionary["accessRequest"] as! NSDictionary
        id = accessRequest["id"] as! String
        dateRequested = moment(accessRequest["dateRequested"] as? String ?? "")?.date
        dateSettled = moment(accessRequest["dateSettled"] as? String ?? "")?.date
        status = Status(rawValue: accessRequest["status"] as! String)
        scopes = (accessRequest["scopes"] as! [String]).flatMap { API.Scopes(rawValue: $0) }
        user = try User(jsonDictionary: jsonDictionary["user"] as! NSDictionary)
    }
}
