//
//  VideoAlbum.swift
//  FUMC
//
//  Created by Andrew Branch on 10/10/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

import UIKit

public class VideoAlbum: NSObject {
    
    var id: String
    var name: String
    var descript: String?
    var videos: [Video] = []
    var featured: Bool
    
    init(jsonDictionary: NSDictionary, dateFormatter: NSDateFormatter, included: [NSDictionary]?) {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let attrs = jsonDictionary["attributes"] as! NSDictionary
        self.id = jsonDictionary["id"] as! String
        self.name = attrs["name"] as! String
        self.descript = attrs["description"] as? String
        self.featured = attrs["featured"] as! Bool
        if let includedVideos = included {
            let videos = ((jsonDictionary["relationships"] as! NSDictionary)["videos"] as! NSDictionary)["data"] as! [NSDictionary]
            for json in videos {
                if let videoDictionary = includedVideos.find({ v in
                    return v["id"] as! String == json["id"] as! String
                }) {
                    do {
                        let video = try Video(jsonDictionary: videoDictionary, dateFormatter: dateFormatter)
                        self.videos.append(video)
                    } catch {}
                }
            }
        }

        super.init()
    }
}
