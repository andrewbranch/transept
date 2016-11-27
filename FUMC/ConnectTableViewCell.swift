//
//  ConnectTableViewCell.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/15/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class ConnectTableViewCell: UITableViewCell {
    
    @IBOutlet var iconView: UIImageView?
    @IBOutlet var label: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
