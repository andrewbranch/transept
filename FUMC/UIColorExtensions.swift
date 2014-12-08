//
//  UIColorExtensions.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

extension UIColor {
    class func fumcRedColor() -> UIColor {
        return UIColor(red: 132/255, green: 21/255, blue: 33/255, alpha: 1)
    }
    class func fumcMagentaColor() -> UIColor {
        return UIColor(red: 190/255, green: 64/255, blue: 127/255, alpha: 1)
    }
    class func fumcNavyColor() -> UIColor {
        return UIColor(red: 10/255, green: 89/255, blue: 124/255, alpha: 1)
    }
    
    // Assumes input like "#00FF00" (#RRGGBB).
    class func colorWithHexString(hexString: String) -> UIColor {
        var rgbValue: UInt32 = 0;
        let scanner = NSScanner(string: hexString)
        scanner.scanLocation = 1 // bypass '#' character
        scanner.scanHexInt(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0, green: CGFloat((rgbValue & 0xFF00) >> 8)/255.0, blue: CGFloat(rgbValue & 0xFF)/255.0, alpha:1.0)
    }
}