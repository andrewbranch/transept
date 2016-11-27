//
//  VideosDataSource.swift
//  FUMC
//
//  Created by Andrew Branch on 9/13/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import UIKit

open class VideosDataSource: NSObject, MediaTableViewDataSource, UITableViewDataSource {
    
    open var delegate: MediaTableViewDataSourceDelegate?
    open var title: NSString = "Videos"
    open var loading = false
    var albums: [VideoAlbum] = []
    
    fileprivate func getError() -> NSError {
        return NSError(domain: Bundle.main.bundleIdentifier!, code: 5, userInfo: [
            "message": "There was an error getting videos."
        ])
    }
    
    required public init(delegate: MediaTableViewDataSourceDelegate?) {
        super.init()
        self.delegate = delegate
    }
    
    open func refresh() {
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
    
    open func requestData(_ completed: @escaping (_ albums: [VideoAlbum], _ error: Error?) -> Void) {
        API.shared().getVideos() { albums, error in
            guard error == nil else {
                completed([], error)
                return
            }
            completed(albums, nil)
        }
    }
    
    open func urlForIndexPath(_ indexPath: IndexPath) -> URL? {
        return nil
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count + 1
    }
    
    open func albumForIndexPath(_ indexPath: IndexPath) -> VideoAlbum? {
        guard indexPath.section == 0 else {
            return nil
        }
        
        return albums[indexPath.row - 1]
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoAlbumsTableViewCell", for: indexPath)
        cell.textLabel!.text = indexPath.row == 0 ? "Live Stream" : albumForIndexPath(indexPath)?.name
        return cell
    }
    
}
