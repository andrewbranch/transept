//
//  CalendarTableHeaderView.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/11/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CalendarTableHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var label: UILabel?
    var border: CALayer?
    
    override func awakeFromNib() {
        self.border = CALayer()
        alignBorder()
        self.border!.backgroundColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.layer.addSublayer(self.border!)
    }
    
    func alignBorder() {
        self.border!.frame = CGRectMake(0, self.frame.height - 1, self.frame.width, 1)
    }

}
