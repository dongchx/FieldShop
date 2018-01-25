//
//  DOColor.swift
//  color
//
//  Created by Dennis Oberhoff on 04/02/16.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public var name: String {
        struct Colors {
            static let Values: [String : [Int]]! = {
                let path = NSBundle.mainBundle().pathForResource("colors", ofType: "plist", inDirectory: "Colors.bundle")
                let data = NSDictionary(contentsOfFile: path!)
                return data as! [String : [Int]]!
            } ()
        }
        
        let colorRef = CGColorGetComponents(self.CGColor);
        let red = Float(colorRef[0] * 255)
        let green = Float(colorRef[1] * 255)
        let blue = Float(colorRef[2] * 255)
        
        var lastDistance = Float(CGFloat.max)
        var colorName : String!
        let colorData = Colors.Values
        
        for (key, values) in colorData {
            let compareRed = Float(values[0])
            let compareGreen = Float(values[1])
            let compareBlue = Float(values[2])
            let distance = sqrt(powf(compareRed - red, 2) + powf(compareGreen - green, 2) + powf(compareBlue - blue, 2))
            if (lastDistance > distance) {
                lastDistance = distance
                colorName = String(key)
            }
        }
        return colorName
    }
    
}