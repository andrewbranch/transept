//
//  VideosDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 9/13/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import UIKit

public class VideosDataSource: NSObject, MediaTableViewDataSource, UITableViewDataSource {
    
    public var delegate: MediaTableViewDataSourceDelegate?
    public var title: NSString = "Videos"
    public var loading = false
    var videos: [Video] = []
    
    private func getError() -> NSError {
        return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 5, userInfo: [
            "message": "There was an error connecting to Vimeo."
        ])
    }
    
    required public init(delegate: MediaTableViewDataSourceDelegate?) {
        super.init()
        self.delegate = delegate
    }
    
    public func refresh() {
        self.delegate?.dataSourceDidStartLoadingAPI(self)
        requestData() { videos, err in
            guard err == nil else {
                self.delegate?.dataSource(self, failedToLoadWithError: err)
                return
            }
            
            self.videos = videos
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    public func requestData(completed: ([Video], NSError?) -> Void) {
        
    }
    
    public func urlForIndexPath(indexPath: NSIndexPath) -> NSURL? {
        return nil
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    public func videoForIndexPath(indexPath: NSIndexPath) -> Video? {
        guard indexPath.section == 0 else {
            return nil
        }
        
        return videos[indexPath.row]
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videosTableViewCell", forIndexPath: indexPath)
        cell.textLabel!.text = videoForIndexPath(indexPath)?.name
        return cell
    }
    
}
