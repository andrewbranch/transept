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
    var albums: [VideoAlbum] = []
    
    private func getError() -> NSError {
        return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 5, userInfo: [
            "message": "There was an error getting videos."
        ])
    }
    
    required public init(delegate: MediaTableViewDataSourceDelegate?) {
        super.init()
        self.delegate = delegate
    }
    
    public func refresh() {
        self.delegate?.dataSourceDidStartLoadingAPI(self)
        requestData() { albums, err in
            guard err == nil else {
                self.delegate?.dataSource(self, failedToLoadWithError: err)
                return
            }
            
            self.albums = albums
            self.delegate?.dataSourceDidFinishLoadingAPI(self)
        }
    }
    
    public func requestData(completed: (albums: [VideoAlbum], error: ErrorType?) -> Void) {
        API.shared().getVideos() { albums, error in
            guard error == nil else {
                completed(albums: [], error: error)
                return
            }
            completed(albums: albums, error: nil)
        }
    }
    
    public func urlForIndexPath(indexPath: NSIndexPath) -> NSURL? {
        return nil
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    public func albumForIndexPath(indexPath: NSIndexPath) -> VideoAlbum? {
        guard indexPath.section == 0 else {
            return nil
        }
        
        return albums[indexPath.row]
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("videoAlbumsTableViewCell", forIndexPath: indexPath)
        cell.textLabel!.text = albumForIndexPath(indexPath)?.name
        return cell
    }
    
}
