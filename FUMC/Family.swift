//
//  Family.swift
//  FUMC
//
//  Created by Andrew Branch on 11/13/16.
//  Copyright © 2016 FUMC Pensacola. All rights reserved.
//

import Foundation
import RealmSwift

class Family: Object {
    
    dynamic var id: String!
    dynamic var isDeleted = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
