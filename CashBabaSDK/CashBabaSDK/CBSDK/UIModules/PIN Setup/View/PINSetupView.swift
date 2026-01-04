//
//  PINSetupView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

class PINSetupView: UIView {

    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .white
        let mainConatinerView = UIView()
        mainConatinerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainConatinerView)
        
        mainConatinerView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
        
        mainConatinerView.addSubview(cashLogoImgView)
        cashLogoImgView.addAnchorToSuperview(top: 16, widthMutiplier: 0.368, centeredHorizontally: 0, heightWidthRatio: 0.203)
        
        mainConatinerView.addSubview(verifyTitle)
        verifyTitle.topAnchor.constraint(equalTo: cashLogoImgView.bottomAnchor, constant: 16).isActive = true
        verifyTitle.addAnchorToSuperview(leading: 16, trailing: -16, centeredHorizontally: 0)
        
        mainConatinerView.addSubview(verifySubTitle)
        verifySubTitle.topAnchor.constraint(equalTo: verifyTitle.bottomAnchor, constant: 10).isActive = true
        verifySubTitle.addAnchorToSuperview(leading: 16, trailing: -16,  centeredHorizontally: 0)
        
        mainConatinerView.addSubview(pinField)
        pinField.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        pinField.topAnchor.constraint(equalTo: verifySubTitle.bottomAnchor, constant: 20).isActive = true
        
        mainConatinerView.addSubview(confirmPinField)
        confirmPinField.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        confirmPinField.topAnchor.constraint(equalTo: pinField.bottomAnchor, constant: 20).isActive = true
        
        
        
        // Add verifyButton to the view hierarchy
        mainConatinerView.addSubview(submitButton)
        submitButton.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        submitButton.topAnchor.constraint(equalTo: confirmPinField.bottomAnchor, constant: 30).isActive = true
        
        mainConatinerView.addSubview(securePinTextContainer)
        securePinTextContainer.addAnchorToSuperview(leading: 16, trailing: -16)
        securePinTextContainer.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 30).isActive = true
    }
    
    lazy var cashLogoImgView: UIImageView = {
        let cash = UIImageView()
        cash.translatesAutoresizingMaskIntoConstraints = false
        cash.image = UIImage.imageFromBundle(OTPVerificationView.self, imageName: "CBLogo")
        return cash
    }()
    
    lazy var verifyTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "pin_setup_title".sslComLocalized()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont(name: FontManager.shared.fonts.esRebondBold, size: 24)
        return label
    }()
    
    lazy var verifySubTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontManager.shared.fonts.interRegular, size: 14)
        label.textColor = UIColor(red: 99/255, green: 102/255, blue: 106/255, alpha: 1.0)
        label.text = "pin_setup_message".sslComLocalized()
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    lazy var pinField: PinInputView = {
        let view = PinInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setPlaceholderHidden(false)
        return view
    }()
    
    lazy var confirmPinField: PinInputView = {
        let view = PinInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinTextField.placeholder = "confirm_pin".sslComLocalized()
        view.setPlaceholderHidden(false)
        return view
    }()
    
    lazy var submitButton: CustomGradientView = {
        let view = CustomGradientView(
            title: "submit".sslComLocalized(),
            titleColor: .white,
            font: UIFont(name: FontManager.shared.fonts.interBold, size: 16) ?? .boldSystemFont(ofSize: 18),
            startColor: UIColor(hex: "#FF9C4E") ?? .systemOrange.withAlphaComponent(0.3),
            endColor: UIColor(hex: "#F87005") ?? .systemOrange
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var securePinTextContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = true
        view.addArrangedSubview(secutePINTitle)
        view.addArrangedSubview(instructionStack)
        return view
    }()
    
    lazy var instructionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var secutePINTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "pin_instruction_title".sslComLocalized()
        label.textColor = UIColor(hex: "#662E91", alpha: 1.0)
        label.numberOfLines = 2
        label.font = UIFont(name: FontManager.shared.fonts.kohinoorMedium, size: 12)
        return label
    }()
}
