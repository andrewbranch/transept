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
    var dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        registerWithVideos()
        
        self.tableView.register(UINib(nibName: "VideosTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "videoCell")
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
    
    func video(_ video: Video, didLoadThumbnail thumbnail: UIImage) {
        let cell = self.tableView!.cellForRow(at: indexPathForVideo(video)) as! VideosTableViewCell
        cell.thumbnail!.image = thumbnail
        cell.thumbnail!.setNeedsDisplay()
    }
    
    func videoAtIndexPath(_ indexPath: IndexPath) -> Video {
        return videos[indexPath.row]
    }

    func indexPathForVideo(_ video: Video) -> IndexPath {
        return IndexPath(row: videos.index(of: video)!, section: 0)
    }
    
    func urlForIndexPath(_ indexPath: IndexPath) -> URL? {
        return URL(string: videoAtIndexPath(indexPath).fileHD)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideosTableViewCell
        let video = videoAtIndexPath(indexPath)
        
        cell.titleLabel!.text = video.name
        cell.dateLabel!.text = dateFormatter.string(from: video.date as Date)
        cell.durationLabel!.text = "\(video.duration / 60) min"
        cell.thumbnail!.image = video.thumbnail
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "playVideoSegue", sender: indexPath)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "playVideoSegue") {
            let viewController = segue.destination as! AVPlayerViewController
            let indexPath = self.tableView!.indexPathForSelectedRow!
            viewController.player = AVPlayer(url: urlForIndexPath(indexPath)!)
            viewController.player?.play()
            let video = videoAtIndexPath(indexPath)
            
            #if !DEBUG
            Answers.logCustomEvent(withName: "Video played", customAttributes: [
                "Name": video.name,
                "Album": self.title ?? "",
                "URL": video.fileHD
            ])
            #endif
        }
    }

}
