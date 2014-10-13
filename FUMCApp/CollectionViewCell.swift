//
//  CollectionViewCell.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        var animation = CAKeyframeAnimation(keyPath: "transform")
        
        var steps = 100
        var values = NSMutableArray(capacity: steps)
        var value = CGFloat(0.0)
        var e = CGFloat(2.71)
        for (var t = 0; t < steps; t++) {
            value = -pow(e, CGFloat(-0.055 * CGFloat(t))) * cos(0.08 * CGFloat(t)) + 1.0
            values.addObject(NSValue(CATransform3D: CATransform3DMakeScale(value, value, value)))
        }
        animation.values = values;
        
        animation.duration = 0.5
        //animation.fromValue = NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 0))
        //animation.toValue = NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        //animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.51, 0.77, 0.05, 1.33)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.layer.addAnimation(animation, forKey: "transform")
    }
    
}
