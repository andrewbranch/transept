//
//  VideosTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 9/13/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import UIKit

class VideoAlbumsTableViewController: UITableViewController, MediaTableViewDataSourceDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = (UIApplication.sharedApplication().delegate as! AppDelegate).videosDataSource
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - MediaTableViewDataSourceDelegate
    
    func dataSource(dataSource: MediaTableViewDataSource, failedToLoadWithError error: ErrorType?) {
        dispatch_async(dispatch_get_main_queue()) {
            ErrorAlerter.loadingAlertBasedOnReachability().show()
        }
    }
    
    func dataSourceDidStartLoadingAPI(dataSource: MediaTableViewDataSource) {
        return
    }
    
    func dataSourceDidFinishLoadingAPI(dataSource: MediaTableViewDataSource) {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "videosSegue") {
            let indexPath = self.tableView!.indexPathForSelectedRow!
            let viewController = segue.destinationViewController as! VideosTableViewController
            viewController.videos = (self.tableView.dataSource as! VideosDataSource).albumForIndexPath(indexPath)!.videos
        }
    }

}
