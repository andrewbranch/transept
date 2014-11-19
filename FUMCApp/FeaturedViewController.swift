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
        let url = NSURL(string: "https://fumc.herokuapp.com/api/features?active=true")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error != nil || data.length == 0 || (response as NSHTTPURLResponse).statusCode != 200) {
                // TODO
                return
            }
            var err: NSError?
            let jsonDictionaries: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &err) as [NSDictionary]
            if (err != nil || jsonDictionaries.count == 0) {
                // TODO
                return
            }

            // Doesn't work in simulator
            if let deviceImage = self.deviceImageMap[UIDevice.currentDevice().platform()] {
                if let key = jsonDictionaries[0][deviceImage] as? NSString {
                    let fileRequest = NSURLRequest(URL: NSURL(string: "https://fumc.herokuapp.com/api/file/\(key)")!)
                    NSURLConnection.sendAsynchronousRequest(fileRequest, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                        if (error != nil || data.length == 0 || (response as NSHTTPURLResponse).statusCode != 200) {
                            // TODO
                            return
                        }
                        let image = UIImage(data: data)
                        if let img = image {
                            self.imageView!.image = img
                            self.featureId = jsonDictionaries[0]["id"] as? Int
                            if (NSUserDefaults.standardUserDefaults().integerForKey("lastSeenFeatureId") != self.featureId?) {
                                // New feature
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(500 * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
                                    self.pageViewController!.setViewControllers([self], direction: UIPageViewControllerNavigationDirection.Forward, animated: true) { (finished) -> Void in
                                        self.pageViewController!.didTransitionToViewController(self)
                                    }
                                }
                            }
                        } else {
                            // TODO
                        }
                    }
                } else {
                    // TODO
                }
            } else {
                // TODO
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
