//
//  Video.swift
//  FUMC
//
//  Created by Andrew Branch on 10/3/15.
//  Copyright © 2015 FUMC Pensacola. All rights reserved.
//

//internal extension Array {
//    func find (condition: (Element) -> Bool) -> Element? {
//        
//        for value in self {
//            if condition(value) {
//                return value
//            }
//        }
//        
//        return nil
//        
//    }
//}

import UIKit

public class Video: NSObject {
    
    var id: String
    var name: String
    var link: String
    var duration: Int
    var date: NSDate
    var thumbnailURL: String = ""
    var thumbnail: UIImage?
    var fileHD: String
    
    init(jsonDictionary: NSDictionary, dateFormatter: NSDateFormatter) throws {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let attrs = jsonDictionary["attributes"] as! NSDictionary
        self.id = jsonDictionary["id"] as! String
        
        self.date = dateFormatter.dateFromString(attrs["sendDate"] as! String)!
        self.name = attrs["name"] as! String
        self.link = attrs["link"] as! String
        self.duration = attrs["duration"] as! Int
        self.fileHD = attrs["fileHD"] as! String
        super.init()
        
        guard let url = (attrs["pictures"] as! [NSDictionary]).find({ picture in
            return picture["width"] as! Int == 200
        })?["link"] as? String else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        self.thumbnailURL = url
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: NSURL(string: url)!), queue: NSOperationQueue.mainQueue()) { response, data, error in
            guard error == nil else {
                return
            }
            
            
        }
    }

}
