//
//  UIFont.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/13/25.
//

import UIKit

extension UIFont {
    enum FontType {
        case Regular, Medium, Bold, Italic, weight(weight: CGFloat)
    }
    
    class func easyMarchantsFont(_ ofType: FontType, ofSize: CGFloat = 17.0) -> UIFont {
        switch ofType {
        case .Bold:
            return UIFont(name: "AvenirNext-Bold", size: ofSize) ?? .systemFont(ofSize: ofSize, weight: .bold)
        case .Medium:
            return UIFont(name: "AvenirNext-Medium", size: ofSize) ?? .systemFont(ofSize: ofSize, weight: .medium)
        case .Regular:
            return UIFont(name:  "AvenirNext-Regular", size: ofSize) ?? .systemFont(ofSize: ofSize, weight: .regular)
        case .Italic:
            return UIFont(name:"Roboto-italic", size: ofSize) ?? .systemFont(ofSize: ofSize, weight: .light)
        case .weight(weight: let weight):
            return UIFont(name:  "AvenirNext-Regular", size: ofSize)?.withWeight(UIFont.Weight(weight)) ?? .systemFont(ofSize: ofSize, weight: UIFont.Weight(weight))
        }
    }

    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [
            UIFontDescriptor.TraitKey.weight: weight
        ]])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
