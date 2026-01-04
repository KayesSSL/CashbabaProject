//
//  PinInputView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

class PinInputView: UIView, UITextFieldDelegate {
    
    /// Maximum length for the PIN. Defaults to 5, but can be customized.
    public var maxPinLength: Int = 5

    public var isSecure: Bool = true {
        didSet {
            updateEyeButtonImage()
            pinTextField.isSecureTextEntry = isSecure
        }
    }
    
    private let defaultBorderColor = UIColor(hex: "#E2E3E8", alpha: 1.0)
    private let selectedBorderColor = UIColor(hex: "#F87005", alpha: 1.0)
    private let defaultTextColor = UIColor(hex: "#888B92")
    private let filledTextColor = UIColor.black
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.layer.borderColor = defaultBorderColor?.cgColor
        return view
    }()
    
    lazy var pinTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: FontManager.shared.fonts.interRegular, size: 16)
        textField.textColor = defaultTextColor
        textField.textAlignment = .left
        textField.placeholder = "enter_pin".sslComLocalized()
        textField.isSecureTextEntry = true // Default to secure
        textField.keyboardType = .numberPad
        textField.delegate = self // Set delegate
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    lazy var eyeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        // Set initial image with template rendering mode
        if let image = UIImage.imageFromBundle(PinInputView.self, imageName: "hide")?.withRenderingMode(.alwaysTemplate) {
            button.setImage(image, for: .normal)
        }
        button.tintColor = UIColor(hex: "#888B92")
        button.addTarget(self, action: #selector(toggleSecureEntry), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        isSecure = true // ensure starting state
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        isSecure = true
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
        containerView.addSubview(pinTextField)
        containerView.addSubview(eyeButton)
        
        pinTextField.addAnchorToSuperview(leading: 10, top: 5, bottom: -5)
        eyeButton.addAnchorToSuperview(trailing: -10, centeredVertically: 0)
        eyeButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
        eyeButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        pinTextField.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: 0).isActive = true
        
        pinTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        pinTextField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        eyeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        eyeButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    // To hide the placeholder label, you can directly set isHidden property
    func setPlaceholderHidden(_ hidden: Bool) {
        eyeButton.isHidden = hidden
    }
    
    // Get the entered PIN
    func getPin() -> String? {
        return pinTextField.text
    }
    
    @objc
    private func toggleSecureEntry() {
        isSecure.toggle()
        // This fixes cursor jump issue on iOS when toggling secure entry by re-assigning text
        if let currentText = pinTextField.text, pinTextField.isFirstResponder {
            pinTextField.resignFirstResponder()
            pinTextField.becomeFirstResponder()
            pinTextField.text = currentText
        }
    }
    
    private func updateEyeButtonImage() {
        let imageName = isSecure ? "hide" : "view"
        if let image = UIImage.imageFromBundle(PinInputView.self, imageName: imageName)?.withRenderingMode(.alwaysTemplate) {
            eyeButton.setImage(image, for: .normal)
        }
        // The tintColor is set in the button initializer
    }
    
    // MARK: - UITextFieldDelegate (Limit input to maxPinLength digits)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow digits
        let allowedCharacterSet = CharacterSet.decimalDigits
        let replacementCharacterSet = CharacterSet(charactersIn: string)
        if !allowedCharacterSet.isSuperset(of: replacementCharacterSet) && !string.isEmpty {
            return false
        }
        
        // Limit to maxPinLength characters
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxPinLength
    }
    
    // MARK: - UITextFieldDelegate (Selected/Unselected border color)
    func textFieldDidBeginEditing(_ textField: UITextField) {
        containerView.layer.borderColor = selectedBorderColor?.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        containerView.layer.borderColor = defaultBorderColor?.cgColor
    }
    
    // MARK: - Text Color on Input
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField.textColor = filledTextColor
        } else {
            textField.textColor = defaultTextColor
        }
    }
}
