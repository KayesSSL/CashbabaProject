//
//  UIColor.swift
//  ssl_commerz_revamp
//
//  Created by Mausum Nandy on 5/20/21.
//

import Foundation
import UIKit
extension UIColor{

    @objc class var sdkSeparatorColor:UIColor{
        return UIColor.init(hex: "#EEEEEE")!
    }
    
    @nonobjc class var clearBlue: UIColor {
        UIColor.init(hex: "#176eff") ?? .gray
    }
    
    @nonobjc class var CBOrange: UIColor {
        UIColor.init(hex: "#F87005") ?? .gray
    }
    
    @nonobjc class var veryLightPink: UIColor {
        return UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var vermillion: UIColor {
        return UIColor(red: 230.0 / 255.0, green: 65.0 / 255.0, blue: 29.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var greyishBrown: UIColor {
        return UIColor(white: 88.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var brownGrey: UIColor {
        return UIColor(white: 149.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var seperatorColor: UIColor {
        return UIColor(white: 220.0 / 255.0, alpha: 1.0)
    }
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

