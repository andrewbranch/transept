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
import SwiftMoment

public protocol VideoDelegate {
    func video(_ video: Video, didLoadThumbnail thumbnail: UIImage)
}

open class Video: NSObject {
    
    var id: String
    var name: String
    var link: String
    var duration: Int
    var date: Date
    var thumbnailURL: String = ""
    var thumbnail: UIImage?
    var fileHD: String
    var delegate: VideoDelegate?
    
    func splitNameAndDate() {
        let nameComponents = self.name.components(separatedBy: " | ")
        if (nameComponents.count > 1) {
            for component in nameComponents {
                if let date = moment(component) {
                    self.date = date.date
                } else {
                    self.name = component
                }
            }
        }
    }
    
    init(jsonDictionary: NSDictionary, dateFormatter: DateFormatter) throws {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let attrs = jsonDictionary["attributes"] as! NSDictionary
        self.id = jsonDictionary["id"] as! String
        
        self.date = dateFormatter.date(from: attrs["date"] as! String)!
        self.name = attrs["name"] as! String
        self.link = attrs["link"] as! String
        self.duration = attrs["duration"] as! Int
        self.fileHD = attrs["fileHD"] as! String
        super.init()
        
        guard let url = (attrs["pictures"] as! [NSDictionary]).first(where: { picture in
            return picture["width"] as! Int == 200
        })?["link"] as? String else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        self.thumbnailURL = url
        NSURLConnection.sendAsynchronousRequest(URLRequest(url: URL(string: url)!), queue: OperationQueue.main) { response, data, error in
            guard error == nil || data == nil else {
                return
            }
            
            if let image = UIImage(data: data!) {
                self.thumbnail = image
                self.delegate?.video(self, didLoadThumbnail: image)
            }
        }
        
        splitNameAndDate()
    }

}
