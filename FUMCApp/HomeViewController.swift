//
//  FirstViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import TwitterKit

class HomeViewController: UIViewController {
    
    @IBOutlet var segmentedControl: UISegmentedControl?
    var currentViewController: UIViewController?
    var viewControllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let calendarViewController = self.storyboard!.instantiateViewControllerWithIdentifier("calendarViewController") as UIViewController
        
        self.viewControllers.append(UIViewController())
        self.viewControllers.append(calendarViewController)
        self.viewControllers.append(UIViewController())
        
        self.cycleFromViewController(self.currentViewController, to: self.viewControllers[self.segmentedControl!.selectedSegmentIndex])
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    func cycleFromViewController(from: UIViewController?, to: UIViewController?) {
    
        // Do nothing if we are attempting to swap to the same view controller
        if (from === to) {
            return
        }
        
        // Check the newVC is non-nil otherwise expect a crash: NSInvalidArgumentException
        if (to != nil) {
        
            // Set the new view controller frame (in this case to be the size of the available screen bounds)
            // Calulate any other frame animations here (e.g. for the oldVC)
            to!.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + 85, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 85);
            
            // Check the oldVC is non-nil otherwise expect a crash: NSInvalidArgumentException
            if (from != nil) {
            
                // Start both the view controller transitions
                from!.willMoveToParentViewController(nil)
                self.addChildViewController(to!)
                
                // Swap the view controllers
                // No frame animations in this code but these would go in the animations block
                self.transitionFromViewController(from!, toViewController: to!, duration: 0.25, options: UIViewAnimationOptions.LayoutSubviews, animations: nil) { (Bool) -> Void in
                    // Finish both the view controller transitions
                    from!.removeFromParentViewController()
                    to!.didMoveToParentViewController(self)
                    // Store a reference to the current controller
                    self.currentViewController = to!
                }
            
            } else {
                
                // Otherwise we are adding a view controller for the first time
                // Start the view controller transition
                self.addChildViewController(to!)
                
                // Add the new view controller view to the ciew hierarchy
                self.view.addSubview(to!.view)
                
                // End the view controller transition
                to!.didMoveToParentViewController(self)
                
                // Store a reference to the current controller
                self.currentViewController = to!
            }
        }
    }
    
    @IBAction func indexDidChangeForSegmentedControl(sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex;
        
        if (UISegmentedControlNoSegment != index) {
            let incomingViewController = self.viewControllers[index]
            self.cycleFromViewController(self.currentViewController, to: incomingViewController)
        }
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

