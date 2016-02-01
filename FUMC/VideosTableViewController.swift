//
//  VideosTableViewController.swift
//  FUMC
//
//  Created by Andrew Branch on 10/11/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Crashlytics

class VideosTableViewController: UITableViewController, VideoDelegate {
    
    var videos: [Video] = []
    var dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMMM d"
        registerWithVideos()
        
        self.tableView.registerNib(UINib(nibName: "VideosTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "videoCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerWithVideos() {
        self.videos.forEach { v in
            v.delegate = self
        }
    }
    
    // MARK: - Video delegate
    
    func video(video: Video, didLoadThumbnail thumbnail: UIImage) {
        let cell = self.tableView!.cellForRowAtIndexPath(indexPathForVideo(video)) as! VideosTableViewCell
        cell.thumbnail!.image = thumbnail
        cell.thumbnail!.setNeedsDisplay()
    }
    
    func videoAtIndexPath(indexPath: NSIndexPath) -> Video {
        return videos[indexPath.row]
    }

    func indexPathForVideo(video: Video) -> NSIndexPath {
        return NSIndexPath(forRow: videos.indexOf(video)!, inSection: 0)
    }
    
    func urlForIndexPath(indexPath: NSIndexPath) -> NSURL? {
        return NSURL(string: videoAtIndexPath(indexPath).fileHD)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videoCell", forIndexPath: indexPath) as! VideosTableViewCell
        let video = videoAtIndexPath(indexPath)
        
        cell.titleLabel!.text = video.name
        cell.dateLabel!.text = dateFormatter.stringFromDate(video.date)
        cell.durationLabel!.text = "\(video.duration / 60) min"
        cell.thumbnail!.image = video.thumbnail
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("playVideoSegue", sender: indexPath)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "playVideoSegue") {
            let viewController = segue.destinationViewController as! AVPlayerViewController
            let indexPath = self.tableView!.indexPathForSelectedRow!
            viewController.player = AVPlayer(URL: urlForIndexPath(indexPath)!)
            viewController.player?.play()
            let video = videoAtIndexPath(indexPath)
            
            Answers.logCustomEventWithName("Video played", customAttributes: [
                "Name": video.name,
                "Album": self.title ?? "",
                "URL": video.fileHD,
                "debug": AppDelegate.debug
            ])
        }
    }

}
