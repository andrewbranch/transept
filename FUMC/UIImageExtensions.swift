//
//  UIImageExtensions.swift
//  FUMCApp
//
//  Created by Andrew Branch on 11/24/14.
//  Copyright (c) 2014 FUMC Pensacola. All rights reserved.
//

extension UIImage {
    class func imageFromColor(color: UIColor, forSize size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Begin a new image that will be the new image with the rounded corners
        // (here with the size of an UIImageView)
        UIGraphicsBeginImageContext(size);
        
        // Draw your image
        image.drawInRect(rect)
        
        // Get the image, here setting the UIImageView image
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext()
        
        return image
    }
}