//
//  CBPopUpView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/13/25.
//
import UIKit

class CBPopUpView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var buttonCallBack:((_ sender:PopupButton)->Void)?
    convenience init(options: [CBPopUpOptions]) {
        self.init(frame:.zero)
        backgroundColor =  UIColor.black.withAlphaComponent(0.3)
        
        let contentView = UIView()
        contentView.backgroundColor = .white
        addSubview(contentView)
        contentView.layer.cornerRadius = 10
        contentView.addAnchorToSuperview(leading: 20, trailing: -20,centeredVertically: 0)
        
        let stack = UIStackView()
        stack.axis = .vertical
        contentView.addSubview(stack)
        stack.addAnchorToSuperview(leading: 0, trailing: 0, top: -8, bottom: 0)
        
        
        options.forEach { option in
            switch option{
            case .bannerImage(image: let image):
                let imageHolder = UIView()
                imageHolder.backgroundColor = .clear
                imageHolder.addSubview(statusIV)
                statusIV.image = image.image
                statusIV.addAnchorToSuperview(leading: 0, trailing: 0,top:0 ,bottom: 0)
                statusIV.heightAnchor.constraint(equalToConstant: .calculatedHeight(290)).isActive = true
                stack.addArrangedSubview(imageHolder)
                
            case .image(image: let image):
                let imageHolder = UIView()
                imageHolder.backgroundColor = .clear
                imageHolder.addSubview(statusIV)
                statusIV.image = image.image
                statusIV.addAnchorToSuperview(top: 16, bottom: 0, centeredHorizontally:0)
                statusIV.heightAnchor.constraint(equalToConstant: .calculatedHeight(120)).isActive = true
                statusIV.widthAnchor.constraint(equalTo: statusIV.heightAnchor).isActive = true
                stack.addArrangedSubview(imageHolder)
            case .title(str: let str,color: let color):
                titleLabel.text = str
                titleLabel.textColor = color
                stack.addArrangedSubview(titleLabel)
            case .subtitle(str: let str,color: let color):
                let subtitleHolder = UIView()
                subtitleHolder.backgroundColor = .clear
                subtitleHolder.addSubview(subTitleLabel)
                subTitleLabel.text = str
                subTitleLabel.textColor = color
                subTitleLabel.addAnchorToSuperview(leading: 20, trailing: -20, top: 5, bottom: -5)
                stack.addArrangedSubview(subtitleHolder)
            case .consent(str: let str,color: let color):
                let consentHolder = UIView()
                consentHolder.addSubview(consentButton)
                consentHolder.addSubview(consentLabel)
                consentLabel.text = str
                consentLabel.textColor = color
                consentLabel.addAnchorToSuperview(trailing: -20, top: 15, bottom: -5)
                consentButton.addAnchorToSuperview(leading:20 , top: 13,heightMultiplier: 0.5,heightWidthRatio: 1)
                consentLabel.leadingAnchor.constraint(equalTo:consentButton.trailingAnchor , constant: 1).isActive = true
                stack.addArrangedSubview(consentHolder)
            case .buttons(buttons:let buttons):
                let buttonsHolder = UIView()
                buttonsHolder.addSubview(buttonsStack)
                buttonsStack.addAnchorToSuperview(leading: 20, trailing:-20, top: 10, bottom: -20)
                stack.addArrangedSubview(buttonsHolder)
                buttons.forEach { btn in
                    btn.translatesAutoresizingMaskIntoConstraints = false
                    btn.heightAnchor.constraint(equalToConstant: .calculatedHeight(46)).isActive = true
                    btn.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
                    buttonsStack.addArrangedSubview(btn)
                }

          
            }
        }
        
        
        
    }
    @objc func buttonAction(_ sender: PopupButton){
        buttonCallBack?(sender)
    }
    let statusIV: UIImageView = {
        let statusIV = UIImageView()
        statusIV.contentMode = .scaleAspectFit
        
        statusIV.image = UIImage(named: "billpayment")
        statusIV.translatesAutoresizingMaskIntoConstraints = false
        return statusIV
    }()
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontManager.shared.fonts.robotoBold, size: 20) //.EasyFont(ofSize: 20, style: .medium)
        label.textColor = .black
       
        label.textAlignment = .center
        return label
    }()
    let subTitleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontManager.shared.fonts.robotoRegular, size: 13) //.EasyFont(ofSize: 13.0, style: .regular)
        label.textColor = UIColor(red: 99/255, green: 102/255, blue: 106/255, alpha: 1.0)
       
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let numbersStack: UIStackView = {
        let numbersStack = UIStackView()
        numbersStack.axis = .vertical
        
        numbersStack.backgroundColor = .white
        numbersStack.layer.borderWidth = 1
        numbersStack.layer.borderColor = UIColor.lightGray.cgColor
        numbersStack.layer.cornerRadius = 10
        numbersStack.clipsToBounds = true
        
        return numbersStack
    }()
    lazy var consentButton : UIButton = {
        let consentButton = UIButton()
        consentButton.setImage(UIImage(named: "conditionUnchecked"), for: .normal)
        consented = false
        consentButton.addTarget(self, action: #selector(consentBtnAction(_:)), for: .touchUpInside)
        return consentButton
    }()
    var consented:Bool?
    @objc func consentBtnAction(_ sender:UIButton){
        consented?.toggle()
        if consented == true{
            consentButton.setImage(UIImage(named: "conditionChecked"), for: .normal)
        }else{
            consentButton.setImage(UIImage(named: "conditionUnchecked"), for: .normal)
        }
    }
    
    let consentLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: FontManager.shared.fonts.robotoMedium, size: 11) //.EasyFont(ofSize: 11.0, style: .medium)
        label.textColor = .lightGray
      
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
   
    let buttonsStack: UIStackView = {
        let numbersStack = UIStackView()
        numbersStack.axis = .vertical
        numbersStack.spacing = 10
        
        return numbersStack
    }()
}

enum  PopupButtonType{
    case fill,bordered
}
class PopupButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private init(){
        super.init(frame: .zero)
    }
    
    convenience init(type:PopupButtonType,title:String,tag:Int) {
        self.init()
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont(name: FontManager.shared.fonts.robotoBold, size: 13) //.EasyFont(ofSize: 13, style: .bold)
        layer.cornerRadius = 10
        clipsToBounds = true
        self.tag = tag
        switch  type{
        case .fill:
           setTitleColor(.white, for: .normal)
           backgroundColor = .CBOrange
        case.bordered:
            setTitleColor(.CBOrange, for: .normal)
            backgroundColor = .white
            layer.cornerRadius = 10
            layer.borderWidth  = 1
            layer.borderColor = UIColor.CBOrange.cgColor
        }
    }
    
}
