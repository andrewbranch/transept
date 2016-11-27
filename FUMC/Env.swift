//
//  Env.swift
//  FUMC
//
//  Created by Andrew Branch on 9/12/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import Foundation

class Env: NSObject {
    
    static var env: NSDictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Secrets", ofType: "plist")!)!
    
    class func get(_ key: String) -> String? {
        return self.env[key] as? String
    }
}
