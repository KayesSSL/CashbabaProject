//
//  ConfirmPINView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 11/3/25.
//

import UIKit

class ConfirmPINView: UIView {
    
    
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
        
        mainConatinerView.addSubview(pinConfirmTitle)
        pinConfirmTitle.topAnchor.constraint(equalTo: cashLogoImgView.bottomAnchor, constant: 16).isActive = true
        pinConfirmTitle.addAnchorToSuperview(leading: 16, trailing: -16, centeredHorizontally: 0)
        
        mainConatinerView.addSubview(pinConfirmSubTitle)
        pinConfirmSubTitle.topAnchor.constraint(equalTo: pinConfirmTitle.bottomAnchor, constant: 16).isActive = true
        pinConfirmSubTitle.addAnchorToSuperview(leading: 16, trailing: -16, centeredHorizontally: 0)
        
        mainConatinerView.addSubview(customOTPTextField)
        customOTPTextField.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        customOTPTextField.topAnchor.constraint(equalTo: pinConfirmSubTitle.bottomAnchor, constant: 20).isActive = true
        
        mainConatinerView.addSubview(submitContainer)
        submitContainer.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        submitContainer.topAnchor.constraint(equalTo: customOTPTextField.bottomAnchor, constant: 30).isActive = true
    }
    
    lazy var cashLogoImgView: UIImageView = {
        let cash = UIImageView()
        cash.translatesAutoresizingMaskIntoConstraints = false
        cash.image = UIImage.imageFromBundle(OTPVerificationView.self, imageName: "CBLogo")
        return cash
    }()
    
    lazy var pinConfirmTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "enter_cashbaba_pin".sslComLocalized()
        label.textAlignment = .center
        label.font = UIFont(name: FontManager.shared.fonts.esRebondBold, size: 24)
        return label
    }()
    
    lazy var pinConfirmSubTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "enter_cashbaba_pin_confirm".sslComLocalized()
        label.textAlignment = .center
        label.font = UIFont(name: FontManager.shared.fonts.interMedium, size: 14)
        return label
    }()
    
    lazy var customOTPTextField: DPOTPView = {
        let view = DPOTPView()
        view.count = 5
        view.spacing = 8
        view.isSecureTextEntry = true
        view.fontTextField = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 24) ?? .systemFont(ofSize: 24)
        view.dismissOnLastEntry = true
        view.borderColorTextField = UIColor(red: 206/255, green: 207/255, blue: 222/255, alpha: 1.0)
        view.borderWidthTextField = 0.5
        view.selectedBorderWidthTextField = 1
        view.cornerRadiusTextField = 8
        view.isCursorHidden = false
        return view
    }()
    
    lazy var submitContainer: CustomGradientView = {
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
    
}
