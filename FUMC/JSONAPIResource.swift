//
//  JSONAPIResource.swift
//  FUMC
//
//  Created by Andrew Branch on 11/19/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

struct JSONAPIResource {
    static func getDataArray(_ rawJSON: Data) throws -> [NSDictionary] {
        let jsonDictionary = try JSONSerialization.jsonObject(with: rawJSON, options: .allowFragments) as! NSDictionary
        return jsonDictionary["data"] as! [NSDictionary]
    }
}
