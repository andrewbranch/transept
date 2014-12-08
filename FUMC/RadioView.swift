class RadioView: UIView {
    
    var selected: Bool = false {
        didSet {
            UIView.animateWithDuration(self.fadeTime) {
                self.inner.alpha = self.selected ? 1 : 0
            }
        }
    }
    
    var color: UIColor = UIColor.blackColor() {
        didSet {
            self.layer.borderColor = self.color.CGColor
            self.inner.layer.backgroundColor = self.color.CGColor
        }
    }
    
    var fadeTime: NSTimeInterval = 0
    
    private lazy var inner: UIView = {
        return UIView(frame: CGRectMake(0, 0, 0, 0))
        }()
    
    override init() {
        super.init()
        layout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layout()
    }
    
    override func awakeFromNib() {
        if let color = self.backgroundColor {
            self.color = color
            self.backgroundColor = nil
        }
        layout()
    }
    
    private func layout() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderWidth = self.frame.width / 12
        self.layer.borderColor = self.color.CGColor
        
        self.inner.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.inner.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: self.frame.width * 0.6))
        self.inner.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: self.frame.height * 0.6))
        self.addSubview(inner)
        self.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.inner, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        self.inner.layoutIfNeeded()
        self.inner.layer.cornerRadius = self.inner.frame.width / 2
        self.inner.layer.backgroundColor = self.layer.borderColor
        
        self.inner.alpha = 0
    }
}