//
//  SecurePINLabel.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

import UIKit

class SecurePINLabel: UILabel {

    // Default initializer that can be used for creating the label programmatically
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Custom initializer for creating the label programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults() // Optionally set default properties
    }
    
    // Convenience initializer to easily initialize without frame
    convenience init(text: String? = nil, textColor: UIColor = .black, font: UIFont = UIFont.systemFont(ofSize: 14)) {
        self.init(frame: .zero)
        self.text = text
        self.textColor = textColor
        self.font = font
    }
    
    // Optional setup to define default properties
    private func setupDefaults() {
        self.text = ""
        self.textColor = .black
        self.font = UIFont.systemFont(ofSize: 14)
    }
    
    // Setter methods to change properties after initialization
    func setText(_ text: String?) {
        self.text = text
    }
    
    func setTextColor(_ color: UIColor) {
        self.textColor = color
    }
    
    func setFont(_ font: UIFont) {
        self.font = font
    }
}

