//
//  Colors.swift
//  Twitter
//
//  Created by Raina Wang on 9/30/17.
//  Copyright © 2017 Raina Wang. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let favActive = UIColor(red: 220/255, green: 45/255, blue: 98/255, alpha: 1.0) /* #dc2d62 */
    static let retweetActive = UIColor(red: 50/255, green: 189/255, blue: 105/255, alpha: 1.0) /* #32bd69 */
    static let twiterMain = UIColor(red: 51/255, green: 164/255, blue: 236/255, alpha: 1.0) /* #33a4ec */

    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
