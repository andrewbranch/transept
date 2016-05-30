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
    var id: String!
    var signed: String!
    var scopes: [API.Scopes]!
    var expires: NSDate!
    var rawJSON: NSData!
    
    init(rawJSON: NSData) throws {
        guard let jsonDictionary = try? NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments) else {
            throw NSError(domain: "com.fumcpensacola.com", code: 2, userInfo: nil)
        }
        
        self.id = jsonDictionary["id"] as! String
        self.signed = jsonDictionary["access_token"] as! String
        self.scopes = (jsonDictionary["scopes"] as! [String]).flatMap { API.Scopes(rawValue: $0) }
        self.expires = moment(jsonDictionary["expires"] as! String)!.date
        self.rawJSON = rawJSON
    }
}
