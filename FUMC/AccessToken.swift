//
//  AccessToken.swift
//  FUMC
//
//  Created by Andrew Branch on 3/6/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit
import SwiftMoment

class AccessToken: NSObject {
    var signed: String
    var scopes: [String]
    var expires: NSDate
    var rawJSON: String
    
    init(rawJSON: NSData) throws {
        guard let jsonDictionary = try? NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments) else {
            throw NSError(domain: "com.fumcpensacola.com", code: 2, userInfo: nil)
        }
        
        self.signed = jsonDictionary["access_token"] as! String
        self.scopes = jsonDictionary["scopes"] as! [String]
        self.expires = moment(jsonDictionary["expires"] as! String)!.date
        self.rawJSON = String(data: rawJSON, encoding: NSUTF8StringEncoding)!
    }
}
