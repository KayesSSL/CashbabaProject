//
//  WelcomeView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/27/25.
//

import UIKit

class WelcomeView: UIView {
    
    private let mainConatinerView: UIView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let proceedGradientLayer = CAGradientLayer() // <-- Added this line
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .white
        
        mainConatinerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainConatinerView)
        
        // Add constraints: fill superview (customize as needed)
        mainConatinerView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
        
        // Configure gradient layer for background
        gradientLayer.colors = [
            UIColor(hex: "#EB762F")?.cgColor ?? UIColor.orange.cgColor,
            UIColor(hex: "#6100AB")?.cgColor ?? UIColor.purple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // bottom-center
        mainConatinerView.layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(welcomeTitle)
        welcomeTitle.addAnchorToSuperview(top: 20, centeredHorizontally: 0)
        
        addSubview(cbLogoImageView)
        cbLogoImageView.addAnchorToSuperview(widthMutiplier: 0.4364, centeredHorizontally: 0, heightWidthRatio: 0.21)
        cbLogoImageView.topAnchor.constraint(equalTo: welcomeTitle.bottomAnchor, constant: 20).isActive = true
        
        addSubview(walletImageView)
        walletImageView.addAnchorToSuperview(widthMutiplier: 0.4933, centeredHorizontally: 0, heightWidthRatio: 1.173)
        walletImageView.topAnchor.constraint(equalTo: cbLogoImageView.bottomAnchor, constant: 50).isActive = true
        
        addSubview(proceedButtonContainer)
        proceedButtonContainer.addAnchorToSuperview(leading: 20, trailing: -20, bottom: -60)
        
        // Configure gradient for proceedButtonContainer (left to right)
        proceedGradientLayer.colors = [
            UIColor(hex: "#FF9C4E")?.cgColor ?? UIColor.orange.cgColor,
            UIColor(hex: "#F87005")?.cgColor ?? UIColor.red.cgColor
        ]
        proceedGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // left
        proceedGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)   // right
        proceedButtonContainer.layer.insertSublayer(proceedGradientLayer, at: 0)
        proceedButtonContainer.layer.cornerRadius = 4
        proceedButtonContainer.layer.masksToBounds = true
        
        addSubview(footerTitle)
        footerTitle.addAnchorToSuperview(leading: 30, trailing: -30)
        footerTitle.bottomAnchor.constraint(equalTo: proceedButtonContainer.topAnchor, constant: -40).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure the gradients always fill their views
        gradientLayer.frame = mainConatinerView.bounds
        proceedGradientLayer.frame = proceedButtonContainer.bounds
    }
    
    lazy var welcomeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "welcome_to".sslComLocalized()
        label.textColor = .white
        label.font = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 16)
        return label
    }()
    
    lazy var cbLogoImageView: UIImageView = {
        let uiimageView = UIImageView()
        uiimageView.translatesAutoresizingMaskIntoConstraints = false
        uiimageView.image = UIImage.imageFromBundle(WelcomeView.self, imageName: "cbLogo_white")
        return uiimageView
    }()
    
    lazy var walletImageView: UIImageView = {
        let uiimageView = UIImageView()
        uiimageView.translatesAutoresizingMaskIntoConstraints = false
        uiimageView.image = UIImage.imageFromBundle(WelcomeView.self, imageName: "wallet_shadow")
        return uiimageView
    }()
    
    lazy var footerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "welcome_to_message".sslComLocalized()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont(name: FontManager.shared.fonts.robotoMedium, size: 24)
        label.textAlignment = .center
        return label
    }()
    
    lazy var proceedButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.addSubview(proceedLabel)
        proceedLabel.addAnchorToSuperview(leading: 8, trailing: -8, top: 4, bottom: -4)
        return view
    }()
    
    lazy var proceedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "proceed".sslComLocalized()
        label.font = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 16)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
}

