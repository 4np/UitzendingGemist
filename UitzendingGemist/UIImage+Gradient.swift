//
//  UIImage+Gradient.swift
//  UitzendingGemist
//
//  Created by Jeroen Wesbeek on 02/03/17.
//  Copyright © 2017 Jeroen Wesbeek. All rights reserved.
//

import UIKit

extension UIImage {
    
    // MARK: Add a vertical gradient to the image
    
    func imageWithGradient() -> UIImage? {
        // start image context
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // draw the source image
        draw(at: CGPoint(x: 0, y: 0))
        
        // always execute this at the end
        defer {
            UIGraphicsEndImageContext()
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        
        let bottom = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        let top = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        
        let colors = [top, bottom] as CFArray
        
        // define gradient
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else { return nil }
        
        let startPoint = CGPoint(x: size.width/2, y: 0)
        let endPoint = CGPoint(x: size.width/2, y: size.height)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return finalImage
    }
}
