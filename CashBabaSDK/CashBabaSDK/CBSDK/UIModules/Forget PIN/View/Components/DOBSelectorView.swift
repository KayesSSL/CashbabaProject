//
//  DOBSelectorView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

class DOBSelectorView: UIView {
    
    
    lazy var containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.layer.borderColor = UIColor(hex: "#E2E3E8", alpha: 1.0)?.cgColor
        return view
    }()
    
    lazy var pinTextLabel: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: FontManager.shared.fonts.interRegular, size: 16)
        textField.textAlignment = .left
        textField.placeholder = "Enter PIN"
        textField.isEnabled = false
        return textField
    }()
    
    lazy var calendarImageView: UIImageView = {
        let label = UIImageView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.image = UIImage.imageFromBundle(DOBSelectorView.self, imageName: "calendar")
        return label
    }()
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
        containerView.addSubview(pinTextLabel)
        containerView.addSubview(calendarImageView)
        
        pinTextLabel.addAnchorToSuperview(leading: 16, top: 5, bottom: -5)
        calendarImageView.addAnchorToSuperview(trailing: -16, centeredVertically: 0)
        calendarImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        calendarImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        pinTextLabel.trailingAnchor.constraint(equalTo: calendarImageView.leadingAnchor, constant: 0).isActive = true
        
        pinTextLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        pinTextLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        calendarImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        calendarImageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
    }
    
    @objc private func handleTap() {
        onTap?()  // Call the tap handler closure if defined
    }
    
    // To hide the placeholder label, you can directly set isHidden property
    func setPlaceholderHidden(_ hidden: Bool) {
        calendarImageView.isHidden = hidden
    }
    
    // Get the entered PIN
    func getPin() -> String? {
        return pinTextLabel.text
    }
}
