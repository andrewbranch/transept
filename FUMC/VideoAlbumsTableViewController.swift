//
//  VideosTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 9/13/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Crashlytics

class VideoAlbumsTableViewController: UITableViewController, MediaTableViewDataSourceDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = (UIApplication.sharedApplication().delegate as! AppDelegate).videosDataSource
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEventWithName("Viewed media list", customAttributes: [
            "Name": "Videos"
        ])
        #endif
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        
        let segueId = indexPath.row == 0 ? "liveStreamSegue" : "videosSegue"
        self.performSegueWithIdentifier(segueId, sender: indexPath)
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
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
            case "videosSegue":
                let indexPath = self.tableView!.indexPathForSelectedRow!
                let viewController = segue.destinationViewController as! VideosTableViewController
                let album = (self.tableView.dataSource as! VideosDataSource).albumForIndexPath(indexPath)!
                viewController.videos = album.videos
                viewController.title = album.name
                #if !DEBUG
                Answers.logCustomEventWithName("Viewed video album", customAttributes: [
                    "Name": album.name
                ])
                #endif
                break
            
            case "liveStreamSegue":
                let viewController = segue.destinationViewController as! AVPlayerViewController
                viewController.player = AVPlayer(URL: NSURL(string: "https://yourstreamlive.com/live/2110/hls")!)
                viewController.player?.play()
                #if !DEBUG
                Answers.logCustomEventWithName("Viewed live stream", customAttributes: nil)
                #endif
                break
            
            default:
                return
        }
    }

}
