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
    var videos: [VIMVideo] = []
    
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
    
    public func authenticate(completed: (NSError?) -> Void) {
        guard let session = VIMSession.sharedSession() else {
            completed(getError())
            return
        }
        
        session.authenticateWithClientCredentialsGrant { err in
            guard err == nil else {
                completed(err)
                return
            }
            
            completed(nil)
        }
    }
    
    public func requestData(completed: ([VIMVideo], NSError?) -> Void) {
        guard let session = VIMSession.sharedSession() else {
            completed([], getError())
            return
        }
        guard session.account?.isAuthenticatedWithClientCredentials() == true else {
            authenticate() { err in
                guard err == nil else {
                    completed([], err)
                    return
                }
                
                self.requestData(completed)
            }
            return
        }
        
        let request = VIMRequestDescriptor()
        request.urlPath = "/me/videos?filter=playable&sort=date&direction=desc"
        request.modelClass = VIMVideo.self
        request.modelKeyPath = "data"
        
        session.client.requestDescriptor(request) { response, err in
            guard err == nil else {
                completed([], err)
                return
            }
            
            guard let videos = response?.result as? [VIMVideo] else {
                completed([], self.getError())
                return
            }
            
            completed(videos, nil)
        }
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
    
    public func videoForIndexPath(indexPath: NSIndexPath) -> VIMVideo? {
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
