//
//  FirstViewController.swift
//  FUMCApp
//
//  Created by Andrew Branch on 10/9/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit
import TwitterKit

class HomeViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageControl = UIPageControl()
    var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let calendarViewController = self.storyboard!.instantiateViewControllerWithIdentifier("calendarViewController") as CalendarTableViewController
        let featuredViewController = self.storyboard!.instantiateViewControllerWithIdentifier("featuredViewController") as UIViewController
        
        self.pages = [calendarViewController, featuredViewController]
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([calendarViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        self.pageControl.frame = CGRectMake(self.navigationController!.navigationBar.bounds.size.width / 2, 32, 0, 0)
        self.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        self.pageControl.numberOfPages = self.pages.count
        
        self.navigationController!.navigationBar.setTitleVerticalPositionAdjustment(-8, forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.addSubview(self.pageControl)

    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = find(self.pages, viewController)
        if (index == 0) {
            return nil
        }
        return self.pages[index! - 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = find(self.pages, viewController)
        if (index == self.pages.count - 1) {
            return nil
        }
        return self.pages[index! + 1]
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        self.pageControl.currentPage = find(self.pages, pendingViewControllers.first! as UIViewController)!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

