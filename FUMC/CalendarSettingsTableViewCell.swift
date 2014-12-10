//
//  CalendarSettingsTableViewCell.swift
//  FUMC
//
//  Created by Andrew Branch on 12/5/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CalendarSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet var label: UILabel?
    @IBOutlet var checkView: RadioView?

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.checkView!.selected = selected
    }

}
