//
//  CBErrorView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/29/25.
//
import UIKit

class CBErrorView: UIView {
    
    var buttonCallBack:((_ sender:UIButton)->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame:.zero)
        backgroundColor =  UIColor.black.withAlphaComponent(0.3)
        
        addSubview(conatiner)
        conatiner.addAnchorToSuperview(leading: 16, trailing: -16, bottom: -30) //heightMultiplier: 0.12
        
    }
    
    @objc func buttonAction(_ sender: UIButton){
        buttonCallBack?(sender)
    }
    
    lazy var conatiner: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.addSubview(errorTitle)
        errorTitle.addAnchorToSuperview(leading: 16, trailing: -16, top: 16)
        view.addSubview(errorMessage)
        errorMessage.addAnchorToSuperview(leading: 16, trailing: -16)
        errorMessage.topAnchor.constraint(equalTo: errorTitle.bottomAnchor, constant: 8).isActive = true
        view.addSubview(closeButton)
        closeButton.addAnchorToSuperview(trailing: -16, bottom: -8)
        closeButton.topAnchor.constraint(equalTo: errorMessage.bottomAnchor, constant: 8).isActive = true
        
        return view
    }()
    
    lazy var errorTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "error".sslComLocalized()
        label.font = UIFont(name: FontManager.shared.fonts.interBold, size: 20)
        return label
    }()
    
    lazy var errorMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: FontManager.shared.fonts.interMedium, size: 17)
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitle("close".sslComLocalized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: FontManager.shared.fonts.robotoRegular, size: 11)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }()
}
