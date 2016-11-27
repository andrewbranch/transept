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
        self.tableView.dataSource = (UIApplication.shared.delegate as! AppDelegate).videosDataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRow(at: indexPath, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if !DEBUG
        Answers.logCustomEvent(withName: "Viewed media list", customAttributes: [
            "Name": "Videos"
        ])
        #endif
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        
        let segueId = indexPath.row == 0 ? "liveStreamSegue" : "videosSegue"
        self.performSegue(withIdentifier: segueId, sender: indexPath)
    }

    // MARK: - MediaTableViewDataSourceDelegate
    
    func dataSource(_ dataSource: MediaTableViewDataSource, failedToLoadWithError error: Error?) {
        DispatchQueue.main.async {
            ErrorAlerter.loadingAlertBasedOnReachability().show()
        }
    }
    
    func dataSourceDidStartLoadingAPI(_ dataSource: MediaTableViewDataSource) {
        return
    }
    
    func dataSourceDidFinishLoadingAPI(_ dataSource: MediaTableViewDataSource) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
            case "videosSegue":
                let indexPath = self.tableView!.indexPathForSelectedRow!
                let viewController = segue.destination as! VideosTableViewController
                let album = (self.tableView.dataSource as! VideosDataSource).albumForIndexPath(indexPath)!
                viewController.videos = album.videos
                viewController.title = album.name
                #if !DEBUG
                Answers.logCustomEvent(withName: "Viewed video album", customAttributes: [
                    "Name": album.name
                ])
                #endif
                break
            
            case "liveStreamSegue":
                let viewController = segue.destination as! AVPlayerViewController
                viewController.player = AVPlayer(url: URL(string: "https://yourstreamlive.com/live/2110/hls")!)
                viewController.player?.play()
                #if !DEBUG
                Answers.logCustomEvent(withName: "Viewed live stream", customAttributes: nil)
                #endif
                break
            
            default:
                return
        }
    }

}
