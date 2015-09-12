//
//  Env.swift
//  FUMC
//
//  Created by Andrew Branch on 9/12/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

class Env: NSObject {
    
    static var env: NSDictionary = {
        return NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Secrets", ofType: "plist")!)!
    }()
    
    class func get(key: String) -> String? {
        return env[key] as? String
    }
}
