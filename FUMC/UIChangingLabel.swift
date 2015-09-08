//
//  UIChangingLabel.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/20/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class UIChangingLabel: UIView {
    
    var label = UILabel()
    private var timer: NSTimer?
    private var heightConstraint: NSLayoutConstraint?
    
    var changeInterval = NSTimeInterval(3)
    var animationSpeed = NSTimeInterval(0.5)
    var texts: [String]? {
        didSet {
            self.label.text = (self.texts! + [self.texts![0]]).joinWithSeparator("\n")
            self.setHeight()
            self.beginAnimating()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    override func awakeFromNib() {
        
    }
    
    private func setup() {
        self.clipsToBounds = true
        self.label.adjustsFontSizeToFitWidth = false
        self.label.lineBreakMode = NSLineBreakMode.ByClipping
        self.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
    }
    
    private func setHeight() {
        self.label.numberOfLines = 1
        self.label.sizeToFit()
        self.frame = CGRectMake(self.frame.minX, self.frame.minY, self.frame.width, self.label.frame.height)
        if let height = self.heightConstraint {
            self.removeConstraint(height)
        }
        self.heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: self.label.frame.height)
        self.addConstraint(self.heightConstraint!)
        self.layoutIfNeeded()
        self.label.numberOfLines = 0
        self.label.sizeToFit()
    }
    
    func change() {
        UIView.animateWithDuration(self.animationSpeed, delay: self.animationSpeed, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.label.frame = CGRectMake(self.label.frame.minX, self.label.frame.minY - self.frame.height, self.label.frame.width, self.label.frame.height)
        }) { (finished) -> Void in
            if (self.label.frame.minY == -self.frame.height * CGFloat(self.texts!.count)) {
                self.label.frame = CGRectMake(self.label.frame.minX, 0, self.label.frame.width, self.label.frame.height)
            }
        }
    }
    
    func beginAnimating() {
        timer?.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.changeInterval, target: self, selector: "change", userInfo: nil, repeats: true)
    }
}