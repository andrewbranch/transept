//
//  JSONAPIResource.swift
//  FUMC
//
//  Created by Andrew Branch on 11/19/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

struct JSONAPIResource {
    static func getDataArray(rawJSON: NSData) throws -> [NSDictionary] {
        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments)
        return jsonDictionary["data"] as! [NSDictionary]
    }
}
