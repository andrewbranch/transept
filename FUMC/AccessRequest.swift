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
    var digitsId: String!
    var phone: String!
    var twitter: String?
    var facebook: String?
    var email: String?
    
    init(rawJSON: NSData) throws {
        guard let jsonDictionary = try? NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments) else {
            throw NSError(domain: "com.fumcpensacola.com", code: 2, userInfo: nil)
        }
        
        dateRequested = moment(jsonDictionary["date-requested"]! as? String ?? "")?.date
        dateSettled = moment(jsonDictionary["date-settled"]! as? String ?? "")?.date
        status = Status(rawValue: jsonDictionary["status"] as! String)
        scopes = (jsonDictionary["scopes"] as! [String]).flatMap { API.Scopes(rawValue: $0) }
        digitsId = jsonDictionary["digitsId"] as! String
        phone = jsonDictionary["phone"] as! String
        twitter = jsonDictionary["twitter"]! as! String?
        facebook = jsonDictionary["facebook"]! as! String?
        email = jsonDictionary["email"]! as! String?
    }
}
