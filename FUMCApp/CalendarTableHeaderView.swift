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
    
    override func awakeFromNib() {
        var bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 1)
        bottomBorder.backgroundColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.layer.addSublayer(bottomBorder)
    }

}
