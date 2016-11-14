//
//  Member.swift
//  FUMC
//
//  Created by Andrew Branch on 11/13/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import Foundation
import RealmSwift

class Member: Object, Deserializable {
    dynamic var id: String!
    dynamic var firstName: String!
    dynamic var lastName: String!
    dynamic var goesBy: String?
    dynamic var photo: String?
    dynamic var email: String?
    dynamic var phone: String?
    dynamic var isDeleted = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience required init(rawJSON: NSData) throws {
        let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(rawJSON, options: .AllowFragments)
        let attrs = jsonDictionary["attributes"] as! NSDictionary

        guard let firstName = attrs["first-name"] as? String else {
            throw NSError(domain: API.ERROR_DOMAIN, code: 0, userInfo: ["developerMessage": "First name was blank"])
        }
        
        guard let lastName = attrs["last-name"] as? String else {
            throw NSError(domain: API.ERROR_DOMAIN, code: 0, userInfo: ["developerMessage": "Last name was blank"])
        }
        
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        goesBy = attrs["goes-by"] as! String?
        photo = attrs["photo"] as! String?
        isDeleted = attrs["is-deleted"] as! Bool
    }
}
