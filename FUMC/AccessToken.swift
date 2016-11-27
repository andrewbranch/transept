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
    var expires: Date
    var needsVerification: Bool
    var rawJSON: Data
    var user: User
    
    static func mapInit(rawJSON: Data) throws -> [AccessToken] {
        fatalError("No such thing as an array response of access tokens")
    }
    
    init(rawJSON: Data) throws {
        let jsonDictionary = try JSONSerialization.jsonObject(with: rawJSON, options: .allowFragments) as! NSDictionary
        self.id = jsonDictionary["id"] as! String
        self.signed = jsonDictionary["access_token"] as! String
        self.scopes = (jsonDictionary["scopes"] as! [String]).flatMap { API.Scopes(rawValue: $0) }
        self.expires = moment(jsonDictionary["expires"] as! String)!.date
        self.needsVerification = jsonDictionary["needsVerification"] as! Bool
        self.user = try User(jsonDictionary: jsonDictionary["user"]! as! NSDictionary)
        self.rawJSON = rawJSON
    }
}
