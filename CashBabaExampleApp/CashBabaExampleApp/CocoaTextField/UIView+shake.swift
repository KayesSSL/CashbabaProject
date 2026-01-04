//
//  UITextField+shake.swift
//  CocoaTextField
//
//  Created by Edgar Žigis on 10/10/2019.
//  Copyright © 2019 Edgar Žigis. All rights reserved.
//

import UIKit

extension UIView {
    
    func shake(offset: CGFloat = 20) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-offset, offset, -offset, offset, -offset/2, offset/2, -offset/4, offset/4, offset/4 ]
        layer.add(animation, forKey: "shake")
    }
}

extension CocoaTextField {
    /// Forces the field to visually appear focused, without making it first responder.
    func setFocusedAppearance(_ focused: Bool) {
        if focused {
            isFieldActivated = true
            isHintVisible = true
            UIView.animate(withDuration: 0.2) {
                self.updateHint()
                self.hintLabel.textColor = self.activeHintColor
                self.backgroundColor = self.focusedBackgroundColor
                if self.errorLabel.alpha == 0 {
                    self.layer.borderColor = self.focusedBackgroundColor.cgColor
                }
            }
        } else {
            isFieldActivated = false
            isHintVisible = alwaysDisplayHintLabel
            UIView.animate(withDuration: 0.3) {
                self.updateHint()
                self.hintLabel.textColor = self.inactiveHintColor
                self.backgroundColor = self.defaultBackgroundColor
                self.layer.borderColor = self.borderColor.cgColor
            }
        }
    }
}
