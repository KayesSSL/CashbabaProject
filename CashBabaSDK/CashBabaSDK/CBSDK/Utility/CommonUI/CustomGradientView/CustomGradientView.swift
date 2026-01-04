//
//  CustomGradientView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 11/6/25.
//

import UIKit

final class CustomGradientView: UIView {
    
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Initializer
    init(
        title: String,
        titleColor: UIColor = .white,
        font: UIFont = .systemFont(ofSize: 16, weight: .medium),
        startColor: UIColor = .systemBlue,
        endColor: UIColor = .systemTeal
    ) {
        super.init(frame: .zero)
        setupView()
        configure(title: title, titleColor: titleColor, font: font, startColor: startColor, endColor: endColor)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Gradient setup
        layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.cornerRadius = 4
        clipsToBounds = true
        
        // Title label
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Configuration
    func configure(
        title: String,
        titleColor: UIColor,
        font: UIFont,
        startColor: UIColor,
        endColor: UIColor
    ) {
        titleLabel.text = title
        titleLabel.textColor = titleColor
        titleLabel.font = font
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
