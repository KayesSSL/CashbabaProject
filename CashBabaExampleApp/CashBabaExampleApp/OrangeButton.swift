//
//  OrangeButton.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/29/25.
//
import UIKit

class OrangeButton: UIButton {

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    // MARK: - Setup
    private func setupButton() {
        backgroundColor = UIColor.orange
        setTitleColor(.white, for: .normal)
//        titleLabel?.font = UIFont(name: FontManager.shared.fonts.robotoBold, size: 22)
        layer.cornerRadius = 8
        clipsToBounds = true

        // Enable dynamic sizing
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    // MARK: - Intrinsic Size
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 20, height: size.height + 10)
    }
}

