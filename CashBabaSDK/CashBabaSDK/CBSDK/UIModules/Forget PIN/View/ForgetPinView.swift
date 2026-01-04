//
//  ForgetPinView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

class ForgetPinView: UIView {

    // Add a closure property to notify when DOB changes
    var onDOBChanged: (() -> Void)?
    
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
        
        mainConatinerView.addSubview(forgetPinTitle)
        forgetPinTitle.topAnchor.constraint(equalTo: cashLogoImgView.bottomAnchor, constant: 16).isActive = true
        forgetPinTitle.addAnchorToSuperview(centeredHorizontally: 0)
        
        mainConatinerView.addSubview(forgetPinSubTitle)
        forgetPinSubTitle.topAnchor.constraint(equalTo: forgetPinTitle.bottomAnchor, constant: 10).isActive = true
        forgetPinSubTitle.addAnchorToSuperview(centeredHorizontally: 0)
        
        mainConatinerView.addSubview(nidField)
        nidField.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        nidField.topAnchor.constraint(equalTo: forgetPinSubTitle.bottomAnchor, constant: 20).isActive = true
        
        mainConatinerView.addSubview(confirmPinField)
        confirmPinField.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        confirmPinField.topAnchor.constraint(equalTo: nidField.bottomAnchor, constant: 20).isActive = true
        
        // Add verifyButton to the view hierarchy
        mainConatinerView.addSubview(submitButton)
        submitButton.addAnchorToSuperview(leading: 16, trailing: -16, heightMultiplier: 0.07)
        submitButton.topAnchor.constraint(equalTo: confirmPinField.bottomAnchor, constant: 30).isActive = true
    }
    
    lazy var cashLogoImgView: UIImageView = {
        let cash = UIImageView()
        cash.translatesAutoresizingMaskIntoConstraints = false
        cash.image = UIImage.imageFromBundle(OTPVerificationView.self, imageName: "CBLogo")
        return cash
    }()
    
    lazy var forgetPinTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "enter_acc_info".sslComLocalized()
        label.font = UIFont(name: FontManager.shared.fonts.esRebondBold, size: 24)
        label.textAlignment = .center
        return label
    }()
    
    lazy var forgetPinSubTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: FontManager.shared.fonts.interRegular, size: 14)
        label.textColor = UIColor(red: 99/255, green: 102/255, blue: 106/255, alpha: 1.0)
        label.text = "enter_acc_info_to_set_pin".sslComLocalized()
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    lazy var nidField: PinInputView = {
        let view = PinInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinTextField.placeholder = "last_4_digits".sslComLocalized()
        view.isSecure = false
        view.maxPinLength = 4
        view.setPlaceholderHidden(true)
        return view
    }()
    
    lazy var confirmPinField: DOBSelectorView = {
        let view = DOBSelectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinTextLabel.placeholder = "dob".sslComLocalized()
        view.setPlaceholderHidden(false)
        view.onTap = {
            print("tap is working")
            self.selectFromDate()
        }
        return view
    }()
    
    lazy var pinTextContainerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var submitButton: CustomGradientView = {
        let view = CustomGradientView(
            title: "proceed".sslComLocalized(),
            titleColor: .white,
            font: UIFont(name: FontManager.shared.fonts.interBold, size: 16) ?? .boldSystemFont(ofSize: 18),
            startColor: UIColor(hex: "#FF9C4E") ?? .systemOrange.withAlphaComponent(0.3),
            endColor: UIColor(hex: "#F87005") ?? .systemOrange
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //date picker
    lazy var dateView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
     
        let dateView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1500))
        dateView.backgroundColor = UIColor(white: 245.0 / 255.0, alpha: 1.0)
        dateView.layer.cornerRadius = 6
        dateView.addShadow(location: .bottom)
        dateView.addSubview(datePicker)
        datePicker.addAnchorToSuperview(leading: 15, trailing: -15, top:8)
        view.addSubview(dateView)
        dateView.addAnchorToSuperview(leading: 20, trailing: -20,heightMultiplier: 0.5,centeredVertically: 0)
        dateView.addSubview(doneButton)
        doneButton.addAnchorToSuperview(trailing: -15, bottom: -8)
        doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        dateView.addSubview(cancelButton)
        cancelButton.addAnchorToSuperview( bottom: -8)
        cancelButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        cancelButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return view
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("done".sslComLocalized(), for: .normal)
        button.titleLabel?.font = UIFont(name: FontManager.shared.fonts.robotoMedium, size: 16)
        button.setTitleColor(UIColor(hex: "#F87005", alpha: 1.0), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("cancel".sslComLocalized(), for: .normal)
        button.titleLabel?.font = UIFont(name: FontManager.shared.fonts.robotoMedium, size: 16)
        button.setTitleColor(UIColor(hex: "#FF9C4E", alpha: 1.0), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func doneButtonTapped() {
        let selectedDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: selectedDate)
        let anotherDate = CBSDKManager.sharedInstance.date(toTimestamp: dateString, dateFormate: "yyyy-MM-dd HH:mm:ss", expectedDateFormate: "dd MMMM yyyy")
        confirmPinField.pinTextLabel.text = anotherDate
        dateView.removeFromSuperview()
        // Notify when DOB has changed
        onDOBChanged?()
    }
    
    @objc func cancelButtonTapped() {
        dateView.removeFromSuperview()
    }
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.overrideUserInterfaceStyle = .light
            if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
            } else {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        datePicker.tintColor = UIColor(cgColor: UIColor(hex: "#FF9C4E", alpha: 1.0)?.cgColor ?? UIColor.orange.cgColor)
        datePicker.backgroundColor = UIColor(white: 245.0 / 255.0, alpha: 1.0)
        return datePicker
    }()
    
    func appearDateSelector(){
        self.addSubview(dateView)
        dateView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    func selectFromDate() {
        print("selected date")
        appearDateSelector()
    }
}
