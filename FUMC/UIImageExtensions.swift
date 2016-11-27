//
//  UIImageExtensions.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageFromColor(_ color: UIColor, forSize size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Begin a new image that will be the new image with the rounded corners
        // (here with the size of an UIImageView)
        UIGraphicsBeginImageContext(size);
        
        // Draw your image
        image!.draw(in: rect)
        
        // Get the image, here setting the UIImageView image
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext()
        
        return image!
    }
}
