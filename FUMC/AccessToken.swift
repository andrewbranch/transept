//
//  AccessToken.swift
//  FUMC
//
//  Created by Andrew Branch on 3/6/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import SwiftMoment

struct AccessToken : Deserializable {
    var id: String
    var signed: String
    var scopes: [API.Scopes]
    var expires: NSDate
    var needsVerification: Bool
    var rawJSON: NSData
    var user: User
    
    init(rawJSON: NSData) throws {
        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments)
        self.id = jsonDictionary["id"] as! String
        self.signed = jsonDictionary["access_token"] as! String
        self.scopes = (jsonDictionary["scopes"] as! [String]).flatMap { API.Scopes(rawValue: $0) }
        self.expires = moment(jsonDictionary["expires"] as! String)!.date
        self.needsVerification = jsonDictionary["needsVerification"] as! Bool
        self.user = try User(jsonDictionary: jsonDictionary["user"]! as! NSDictionary)
        self.rawJSON = rawJSON
    }
}
