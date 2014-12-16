//
//  FeaturedViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/12/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

class FeaturedViewController: UIViewController, HomeViewPage {
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var label: UILabel?
    
    var pageViewController: HomeViewController?
    private var appearedOnce = false
    private var featureId: Int?
    private let deviceImageMap = [
        "iPhone3,1": "iphoneFourImage",
        "iPhone3,2": "iphoneFourImage",
        "iPhone3,3": "iphoneFourImage",
        "iPhone4,1": "iphoneFourImage",
        "iPhone5,1": "iphoneFiveImage",
        "iPhone5,2": "iphoneFiveImage",
        "iPhone5,3": "iphoneFiveImage",
        "iPhone5,4": "iphoneFiveImage",
        "iPhone6,1": "iphoneFiveImage",
        "iPhone6,2": "iphoneFiveImage",
        "iPhone7,1": "iphoneSixPlusImage",
        "iPhone7,2": "iphoneSixImage",
        "x86_64": "iphoneFiveImage", // Simulator
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.label!.font = UIFont.fumcMainFontRegular26
        self.label!.hidden = false
        loadFeaturedContent()
    }
    
    func loadFeaturedContent() {
        if let key = self.deviceImageMap[UIDevice.currentDevice().platform()] {
            API.shared().getFeaturedContent(key) { image, id, error in
                if (error != nil) {
                    self.imageView!.image = nil
                    self.label!.hidden = false
                    return
                }
                
                if (self.featureId != nil && self.featureId! == id!) {
                    return
                }
                
                self.label!.hidden = true
                self.imageView!.image = image!
                self.featureId = id!
                if (NSUserDefaults.standardUserDefaults().integerForKey("lastSeenFeatureId") != id!) {
                    // New feature
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
                        self.pageViewController!.setViewControllers([self], direction: UIPageViewControllerNavigationDirection.Forward, animated: true) { (finished) -> Void in
                            self.pageViewController!.didTransitionToViewController(self)
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.pageViewController!.didTransitionToViewController(self)
        self.pageViewController!.navigationItem.title = "Featured"
        self.pageViewController!.pageControl.hidden = false
        if let id = self.featureId {
            NSUserDefaults.standardUserDefaults().setInteger(id, forKey: "lastSeenFeatureId")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
