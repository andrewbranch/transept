//
//  ActivityIndicatorView.swift
//  FUMC
//
//  Created by Andrew Branch on 12/11/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    func setup() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        self.backgroundColor = UIColor(white: 0, alpha: 0.75)
        self.layer.cornerRadius = 10
        self.addSubview(activityIndicator)
        activityIndicator.center = self.center
        activityIndicator.startAnimating()
    }

}
