//
//  User.swift
//  FUMC
//
//  Created by Andrew Branch on 5/30/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import UIKit

struct User {
    var id: String
    var firstName: String?
    var lastName: String?
    var twitter: String?
    var facebook: String?
    var email: String?
    var digitsId: String?
    var phone: String?
    var fullName: String? {
        get {
            guard firstName != nil || lastName != nil else {
                return nil
            }

            return "\(firstName) \(lastName)".stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
    }
    
    init(jsonDictionary: NSDictionary) throws {
        id = jsonDictionary["id"] as! String
        firstName = jsonDictionary["firstName"] as! String?
        lastName = jsonDictionary["lastName"] as! String?
        facebook = jsonDictionary["facebook"] as! String?
    }
}
