//
//  CollectionViewCell.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.blackColor();
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
}
