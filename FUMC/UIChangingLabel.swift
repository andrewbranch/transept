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
    fileprivate var timer: Timer?
    fileprivate var heightConstraint: NSLayoutConstraint?
    
    var changeInterval = TimeInterval(3)
    var animationSpeed = TimeInterval(0.5)
    var texts: [String]? {
        didSet {
            self.label.text = (self.texts! + [self.texts![0]]).joined(separator: "\n")
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
    
    fileprivate func setup() {
        self.clipsToBounds = true
        self.label.adjustsFontSizeToFitWidth = false
        self.label.lineBreakMode = NSLineBreakMode.byClipping
        self.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0))
    }
    
    fileprivate func setHeight() {
        self.label.numberOfLines = 1
        self.label.sizeToFit()
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: self.label.frame.height)
        if let height = self.heightConstraint {
            self.removeConstraint(height)
        }
        self.heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: self.label.frame.height)
        self.addConstraint(self.heightConstraint!)
        self.layoutIfNeeded()
        self.label.numberOfLines = 0
        self.label.sizeToFit()
    }
    
    func change() {
        UIView.animate(withDuration: self.animationSpeed, delay: self.animationSpeed, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.label.frame = CGRect(x: self.label.frame.minX, y: self.label.frame.minY - self.frame.height, width: self.label.frame.width, height: self.label.frame.height)
        }) { (finished) -> Void in
            if (self.label.frame.minY == -self.frame.height * CGFloat(self.texts!.count)) {
                self.label.frame = CGRect(x: self.label.frame.minX, y: 0, width: self.label.frame.width, height: self.label.frame.height)
            }
        }
    }
    
    func beginAnimating() {
        timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: self.changeInterval, target: self, selector: #selector(UIChangingLabel.change), userInfo: nil, repeats: true)
    }
}
