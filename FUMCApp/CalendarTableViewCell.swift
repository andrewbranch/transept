//
//  CalendarTableViewCell.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/10/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {
    
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var meridiemLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var locationLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
