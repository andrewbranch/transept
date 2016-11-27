//
//  Member.swift
//  FUMC
//
//  Created by Andrew Branch on 11/13/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import Foundation
import RealmSwift

final class Member: Object, Deserializable {
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
    
    static func mapInit(rawJSON: Data) throws -> [Member] {
        return try JSONAPIResource.getDataArray(rawJSON).map(self.init)
    }
    
    convenience required init(rawJSON: Data) throws {
        let jsonDictionary = try JSONSerialization.jsonObject(with: rawJSON, options: .allowFragments)
        self.init()
        try initAttrs(jsonDictionary as! NSDictionary)
    }
    
    convenience required init(jsonDictionary: NSDictionary) throws {
        self.init()
        try initAttrs(jsonDictionary)
    }
    
    fileprivate func initAttrs(_ jsonDictionary: NSDictionary) throws {
        let attrs = jsonDictionary["attributes"] as! NSDictionary
        guard let firstName = attrs["first-name"] as? String else {
            throw NSError(domain: API.ERROR_DOMAIN, code: 0, userInfo: ["developerMessage": "First name was blank"])
        }
        
        guard let lastName = attrs["last-name"] as? String else {
            throw NSError(domain: API.ERROR_DOMAIN, code: 0, userInfo: ["developerMessage": "Last name was blank"])
        }
        
        self.firstName = firstName
        self.lastName = lastName
        goesBy = attrs["goes-by"] as! String?
        photo = attrs["photo"] as! String?
        isDeleted = attrs["is-deleted"] as! Bool
    }
}
