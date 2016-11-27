class RadioView: UIView {
    
    var selected: Bool = false {
        didSet {
            UIView.animate(withDuration: self.fadeTime, animations: {
                self.inner.alpha = self.selected ? 1 : 0
            }) 
        }
    }
    
    var color: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = self.color.cgColor
            self.inner.layer.backgroundColor = self.color.cgColor
        }
    }
    
    var fadeTime: TimeInterval = 0
    
    fileprivate lazy var inner: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        layout()
    }
    
    override func awakeFromNib() {
        if let color = self.backgroundColor {
            self.color = color
            self.backgroundColor = nil
        }
        layout()
    }
    
    fileprivate func layout() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = self.frame.width / 12
        self.layer.borderColor = self.color.cgColor
        
        self.inner.translatesAutoresizingMaskIntoConstraints = false
        self.inner.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: self.frame.width * 0.6))
        self.inner.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: self.frame.height * 0.6))
        self.addSubview(inner)
        self.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        self.inner.layoutIfNeeded()
        self.inner.layer.cornerRadius = self.inner.frame.width / 2
        self.inner.layer.backgroundColor = self.layer.borderColor
        
        self.inner.alpha = 0
    }
}
