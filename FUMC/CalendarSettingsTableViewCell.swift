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
    @IBOutlet var borderView: UIView?
    @IBOutlet var checkView: UIImageView?
    var color: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderView!.layer.cornerRadius = 10
        self.checkView!.image = self.checkView!.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.checkView!.alpha = 0
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.borderView!.layer.borderWidth = selected ? 2 : 0
        self.checkView!.alpha = selected ? 1 : 0
    }

}
