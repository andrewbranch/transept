//
//  UIFontExtensions.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

private let _MAIN_FONT_REGULAR = "MyriadPro-Regular"
private let _MAIN_FONT_BOLD = "MyriadPro-Semibold"
private let _ALT_FONT_BOLD = "BebasNeueBold"

extension UIFont {
    
    class var fumcMainFontRegular10: UIFont {
        struct Static {
            static let font = UIFont(name: _MAIN_FONT_REGULAR, size: 10)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(10)
    }
    
    class var fumcMainFontRegular14: UIFont {
        struct Static {
            static let font = UIFont(name: _MAIN_FONT_REGULAR, size: 14)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(14)
    }
    
    class var fumcMainFontRegular16: UIFont {
        struct Static {
            static let font = UIFont(name: _MAIN_FONT_REGULAR, size: 16)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(16)
    }
    
    class var fumcMainFontRegular18: UIFont {
        struct Static {
            static let font = UIFont(name: _MAIN_FONT_REGULAR, size: 18)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(18)
    }
    
    class var fumcMainFontRegular20: UIFont {
        struct Static {
            static let font = UIFont(name: _MAIN_FONT_REGULAR, size: 20)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(20)
    }
    
    class var fumcMainFontRegular26: UIFont {
        struct Static {
            static let font = UIFont(name: _MAIN_FONT_REGULAR, size: 26)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(26)
    }
    
    class var fumcMainFontBold18: UIFont {
        struct Static {
            static let font = UIFont(name: _MAIN_FONT_BOLD, size: 18)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(18)
    }
    
    class var fumcAltFontBold22: UIFont {
        struct Static {
            static let font = UIFont(name: _ALT_FONT_BOLD, size: 22)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(22)
    }
    
    class var fumcAltFontBold30: UIFont {
        struct Static {
            static let font = UIFont(name: _ALT_FONT_BOLD, size: 30)
        }
        if let font = Static.font {
            return font
        }
        return UIFont.systemFontOfSize(30)
    }
    
}