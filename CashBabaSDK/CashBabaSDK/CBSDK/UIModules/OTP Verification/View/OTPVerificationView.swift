//
//  OTPVerificationView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//
import UIKit

class OTPVerificationView: UIView {

    
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
        verifySubTitle.addAnchorToSuperview(leading: 16, trailing: -16, centeredHorizontally: 0)
        
        mainConatinerView.addSubview(customOTPTextField)
        customOTPTextField.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        customOTPTextField.topAnchor.constraint(equalTo: verifySubTitle.bottomAnchor, constant: 20).isActive = true
        
        mainConatinerView.addSubview(contStack)
        contStack.addAnchorToSuperview(leading: 16, trailing: -16)
        contStack.topAnchor.constraint(equalTo: customOTPTextField.bottomAnchor, constant: 30).isActive = true
        
        // Add verifyButton to the view hierarchy
        mainConatinerView.addSubview(verifyContainer)
        verifyContainer.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        verifyContainer.topAnchor.constraint(equalTo: contStack.bottomAnchor, constant: 30).isActive = true
        
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
        label.text = "verify_ph_no".sslComLocalized()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont(name: FontManager.shared.fonts.esRebondBold, size: 24)
        return label
    }()
    
    lazy var verifySubTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont(name: FontManager.shared.fonts.interMedium, size: 14)
        return label
    }()
    
    lazy var customOTPTextField: DPOTPView = {
        let view = DPOTPView()
        view.count = 6
        view.spacing = 8
        view.fontTextField = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 24) ?? .systemFont(ofSize: 24)
        view.dismissOnLastEntry = true
        view.borderColorTextField = UIColor(red: 226/255, green: 227/255, blue: 232/255, alpha: 1.0)
        view.borderWidthTextField = 0.5
        view.selectedBorderWidthTextField = 1
        view.cornerRadiusTextField = 8
        view.isCursorHidden = false
        return view
    }()
    
    lazy var sendCodeAgainText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 16)
        label.textAlignment = .left
        label.text = "send_code_again".sslComLocalized()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var timerText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 16)
        label.textColor = UIColor(hex: "#F87005")
        label.textAlignment = .left
        label.text = "00:00"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var contStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 5
        stack.addArrangedSubview(sendCodeAgainText)
        stack.addArrangedSubview(timerText)
        return stack
    }()
    
    lazy var verifyContainer: CustomGradientView = {
        let view = CustomGradientView(
            title: "verify".sslComLocalized(),
            titleColor: .white,
            font: UIFont(name: FontManager.shared.fonts.interBold, size: 16) ?? .boldSystemFont(ofSize: 18),
            startColor: UIColor(hex: "#FF9C4E") ?? .systemOrange.withAlphaComponent(0.3),
            endColor: UIColor(hex: "#F87005") ?? .systemOrange
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
