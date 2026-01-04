//
//  ViewController.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import UIKit
import CashBabaSDK

protocol AlertDelegate: AnyObject {
    func alertDismissed(buttonTitle: String?)
}


class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    lazy var clientID: CocoaTextField = {
        let field = CocoaTextField()
        field.placeholder = "Client ID"
        field.text = "crack_platoon"//"cb_merchant_sdk"
        field.alwaysDisplayHintLabel = true
        return field
    }()
    
    lazy var clientSecret: CocoaTextField = {
        let field = CocoaTextField()
        field.placeholder = "Client Secret"
        field.text = "7d1ab30f6fe84717a94d896fb97f7350"//"Abcd@1234"
        field.alwaysDisplayHintLabel = true
        return field
    }()
    
    lazy var wToken: CocoaTextField = {
        let field = CocoaTextField()
        field.placeholder = "W-Token"
        field.text = "3c3df973-15a3-4b1c-bb9d-5e7f19daf5fe"//"c7b7918d-909c-4b52-a6d4-e05ca79334a3"
        field.alwaysDisplayHintLabel = true
        return field
    }()
    
    lazy var bankTokenNumber: CocoaTextField = {
        let field = CocoaTextField()
        field.placeholder = "Bank Token No."
        field.text = "f216ac78-34e3-4131-a47d-284163703eb0"
        field.alwaysDisplayHintLabel = true
        return field
    }()
    
    lazy var transactionAmount: CocoaTextField = {
        let field = CocoaTextField()
        field.placeholder = "Transaction Amount"
        field.alwaysDisplayHintLabel = true
        return field
    }()
    
    lazy var transactionPurpose: CocoaTextField = {
        let field = CocoaTextField()
        field.placeholder = "Transaction Purpose"
        field.alwaysDisplayHintLabel = true
        return field
    }()
    
    lazy var paymentReference: CocoaTextField = {
        let field = CocoaTextField()
        field.placeholder = "Payment Reference"
        field.text = "J2J5ZXI71K0S"
        field.alwaysDisplayHintLabel = true
        return field
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let con = UISegmentedControl(items: ["SANDBOX", "LIVE"])
        con.translatesAutoresizingMaskIntoConstraints = false
        con.selectedSegmentIndex = 0
        con.backgroundColor = UIColor.systemGray5
        con.selectedSegmentTintColor = UIColor.systemOrange
        con.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        con.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        con.layer.cornerRadius = 16
        con.layer.masksToBounds = true
        return con
    }()
    
    lazy var langSelectControl: UISegmentedControl = {
        let con = UISegmentedControl(items: ["EN", "BN"])
        con.translatesAutoresizingMaskIntoConstraints = false
        con.selectedSegmentIndex = 0
        con.backgroundColor = UIColor.systemGray5
        con.selectedSegmentTintColor = UIColor.systemBlue
        con.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        con.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        con.layer.cornerRadius = 16
        con.layer.masksToBounds = true
        return con
    }()
    
    lazy var formView: ScrollableView = {
        let view = ScrollableView()
        view.contentView.addSubview(segmentedControl)
        segmentedControl.addAnchorToSuperview(top: 10, centeredHorizontally: 0)
        view.contentView.addSubview(langSelectControl)
        langSelectControl.addAnchorToSuperview(centeredHorizontally: 0)
        langSelectControl.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,constant: 10).isActive = true
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        view.contentView.addSubview(stack)
        stack.addAnchorToSuperview(leading: 15, trailing: -15)
        stack.topAnchor.constraint(equalTo: langSelectControl.bottomAnchor,constant: 25).isActive = true
        stack.addArrangedSubview(clientID)
        stack.addArrangedSubview(clientSecret)
        stack.addArrangedSubview(wToken)
        stack.addArrangedSubview(bankTokenNumber)
        stack.addArrangedSubview(transactionAmount)
        stack.addArrangedSubview(transactionPurpose)
        stack.addArrangedSubview(paymentReference)
        
        view.contentView.addSubview(setPinButton)
        setPinButton.addAnchorToSuperview(centeredHorizontally: 0)
        setPinButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 10).isActive = true
        
        view.contentView.addSubview(changePinButton)
        changePinButton.addAnchorToSuperview(centeredHorizontally: 0)
        changePinButton.topAnchor.constraint(equalTo: setPinButton.bottomAnchor, constant: 10).isActive = true
        
        view.contentView.addSubview(forgotPinButton)
        forgotPinButton.addAnchorToSuperview(centeredHorizontally: 0)
        forgotPinButton.topAnchor.constraint(equalTo: changePinButton.bottomAnchor, constant: 10).isActive = true
        
        view.contentView.addSubview(transferButton)
        transferButton.addAnchorToSuperview(centeredHorizontally: 0)
        transferButton.topAnchor.constraint(equalTo: forgotPinButton.bottomAnchor, constant: 10).isActive = true
        
        view.contentView.addSubview(paymentButton)
        paymentButton.addAnchorToSuperview(centeredHorizontally: 0)
        paymentButton.topAnchor.constraint(equalTo: transferButton.bottomAnchor, constant: 10).isActive = true
        
        view.contentView.addSubview(distributorPaymentButton)
        distributorPaymentButton.addAnchorToSuperview(centeredHorizontally: 0)
        distributorPaymentButton.topAnchor.constraint(equalTo: paymentButton.bottomAnchor, constant: 10).isActive = true
        
        view.contentView.addSubview(cpqrcPaymentButton)
        cpqrcPaymentButton.addAnchorToSuperview(bottom: -25, centeredHorizontally: 0)
        cpqrcPaymentButton.topAnchor.constraint(equalTo: distributorPaymentButton.bottomAnchor, constant: 10).isActive = true
        
        return view
    }()
    
    lazy var setPinButton: OrangeButton = {
        let button = OrangeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Set PIN", for: .normal)
        button.addTarget(self, action: #selector(pushVC), for: .touchUpInside)
        return button
    }()
    
    lazy var changePinButton: OrangeButton = {
        let button = OrangeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change PIN", for: .normal)
        button.addTarget(self, action: #selector(changePIN), for: .touchUpInside)
        return button
    }()
    
    lazy var forgotPinButton: OrangeButton = {
        let button = OrangeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Forgot PIN", for: .normal)
        button.addTarget(self, action: #selector(forgotPIN), for: .touchUpInside)
        return button
    }()
    
    lazy var transferButton: OrangeButton = {
        let button = OrangeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Transfer", for: .normal)
        button.addTarget(self, action: #selector(transfer), for: .touchUpInside)
        return button
    }()
    
    lazy var paymentButton: OrangeButton = {
        let button = OrangeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Payment", for: .normal)
        button.addTarget(self, action: #selector(payment), for: .touchUpInside)
        return button
    }()
    
    lazy var distributorPaymentButton: OrangeButton = {
        let button = OrangeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Distributor Payment", for: .normal)
        button.addTarget(self, action: #selector(distributorPayment), for: .touchUpInside)
        return button
    }()
    
    lazy var cpqrcPaymentButton: OrangeButton = {
        let button = OrangeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CPQRC Payment", for: .normal)
        button.addTarget(self, action: #selector(cpqrcPayment), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Keyboard/Scrolling Support
    
    private var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.addSubview(formView)
        formView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
        
        // Set delegate to self for all text fields
        [clientID, clientSecret, wToken, bankTokenNumber, transactionAmount, transactionPurpose, paymentReference].forEach {
            $0.delegate = self
        }

        let hideKeybaordGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_ :)))
        hideKeybaordGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(hideKeybaordGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.clientID.setFocusedAppearance(true)
        self.clientSecret.setFocusedAppearance(true)
        self.wToken.setFocusedAppearance(true)
        self.bankTokenNumber.setFocusedAppearance(true)
        self.paymentReference.setFocusedAppearance(true)
    }
    
    @objc func hideKeyboard(_ sender:UITapGestureRecognizer){
       self.view.endEditing(true)
   }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.height

        // Adjust scrollView's contentInset and scrollIndicatorInsets
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        formView.scrollView.contentInset = insets
        formView.scrollView.scrollIndicatorInsets = insets
        
        // Scroll to active field if needed
        if let activeField = self.activeField {
            // Convert the field's rect to the scrollView's coordinate system
            let fieldRect = activeField.convert(activeField.bounds, to: formView.scrollView)
            formView.scrollView.scrollRectToVisible(fieldRect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        let insets = UIEdgeInsets.zero
        formView.scrollView.contentInset = insets
        formView.scrollView.scrollIndicatorInsets = insets
    }

    @objc func pushVC() {
        do {
            try CashBaba.shared.initialize(environment: .demo, languageCode: "en")
            
            // Present SDK from host
            let args = NavigationArgs(
              type: .SET_PIN,
              wToken: self.wToken.text,
              languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn",
              environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
              clientId: self.clientID.text ?? "",
              clientSecret: self.clientSecret.text ?? "",
              phone: "01681525231"//"01924278435" //"01761864901"
            )
            SDKPresenter.present(from: self, args: args, onSuccess: { result in
              // handle success
                self.showPopUp(isError: false, errorMessage: "PIN Setup success", delegate: self)
            }, onFailed: { failure in
              // show failure.errorMessage
                print("Failure happened! SDK is not loaded!")
                self.showPopUp(isError: true, errorMessage: failure.errorMessage, delegate: self)
            }, onUserCancel: {
              // user closed
                print("SDK is closed!")
                self.showToast(message: "SDK is closed!")
            })
        } catch {
            // Handle the error (for example, present an alert)
            let alert = UIAlertController(title: "Initialization Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc func changePIN() {
        do {
            try CashBaba.shared.initialize(environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                                              languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn")

            let args = NavigationArgs(
                type: .CHANGE_PIN,
                wToken: self.wToken.text,
                languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn",
                environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                clientId: self.clientID.text ?? "",
                clientSecret: self.clientSecret.text ?? ""
            )
            SDKPresenter.present(from: self, args: args, onSuccess: { result in
                // handle success if needed
                self.showPopUp(isError: false, errorMessage: "PIN Change success", delegate: self)
            }, onFailed: { failure in
                self.showPopUp(isError: true, errorMessage: failure.errorMessage, delegate: self)
            }, onUserCancel: {
                self.showToast(message: "SDK is closed!")
            })
        } catch {
            let alert = UIAlertController(title: "Initialization Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc func forgotPIN() {
        do {
            try CashBaba.shared.initialize(environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                                              languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn")

            let args = NavigationArgs(
                type: .FORGET_PIN,
                wToken: self.wToken.text,
                languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn",
                environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                clientId: self.clientID.text ?? "",
                clientSecret: self.clientSecret.text ?? ""
            )
            SDKPresenter.present(from: self, args: args, onSuccess: { result in
                // handle success
                self.showPopUp(isError: false, errorMessage: "Forget PIN Setup success", delegate: self)
            }, onFailed: { failure in
                self.showPopUp(isError: true, errorMessage: failure.errorMessage, delegate: self)
            }, onUserCancel: {
                self.showToast(message: "SDK is closed!")
            })
        } catch {
            let alert = UIAlertController(title: "Initialization Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        
    }
    
    
    
    @objc func transfer() {
        guard let amount = self.transactionAmount.text, !amount.isEmpty else {
            self.showPopUp(isError: true, errorMessage: "Transaction amount must not be empty!", delegate: self)
            return
        }
        guard let bankToken = self.bankTokenNumber.text, !bankToken.isEmpty else {
            self.showPopUp(isError: true, errorMessage: "Bank token must not be empty!", delegate: self)
            return
        }
        let purpose = self.transactionPurpose.text ?? ""

        do {
            try CashBaba.shared.initialize(environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                                              languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn")

            let info = TransferInfo(bankTokenNo: bankToken, transactionAmount: amount, purpose: purpose)
            let args = NavigationArgs(
                type: .TRANSFER_MONEY,
                wToken: self.wToken.text,
                languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn",
                environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                clientId: self.clientID.text ?? "",
                clientSecret: self.clientSecret.text ?? "",
                transferInfo: info
            )
            SDKPresenter.present(from: self, args: args, onSuccess: { result in
                // handle success if needed
            }, onFailed: { failure in
                self.showPopUp(isError: true, errorMessage: failure.errorMessage, delegate: self)
            }, onUserCancel: {
                self.showToast(message: "SDK is closed!")
            })
        } catch {
            let alert = UIAlertController(title: "Initialization Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc func payment() {
            guard let reference = self.paymentReference.text, !reference.isEmpty else {
                self.showPopUp(isError: true, errorMessage: "Payment reference must not be empty!", delegate: self)
                return
            }
            do {
                try CashBaba.shared.initialize(environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                                                  languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn")

                let args = NavigationArgs(
                    type: .PAYMENT,
                    wToken: self.wToken.text,
                    languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn",
                    environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                    paymentReference: reference,
                    clientId: self.clientID.text ?? "",
                    clientSecret: self.clientSecret.text ?? ""
                )
                SDKPresenter.present(from: self, args: args, onSuccess: { result in
                    // handle success if needed
                }, onFailed: { failure in
                    self.showPopUp(isError: true, errorMessage: failure.errorMessage, delegate: self)
                }, onUserCancel: {
                    self.showToast(message: "SDK is closed!")
                })
            } catch {
                let alert = UIAlertController(title: "Initialization Failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    
    @objc func distributorPayment() {
        guard let reference = self.paymentReference.text, !reference.isEmpty else {
            self.showPopUp(isError: true, errorMessage: "Payment reference must not be empty!", delegate: self)
            return
        }
        do {
            try CashBaba.shared.initialize(environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                                              languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn")

            let args = NavigationArgs(
                type: .DISTRIBUTOR_PAYMENT,
                wToken: self.wToken.text,
                languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn",
                environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                paymentReference: reference,
                clientId: self.clientID.text ?? "",
                clientSecret: self.clientSecret.text ?? ""
            )
            SDKPresenter.present(from: self, args: args, onSuccess: { result in
                // handle success if needed
            }, onFailed: { failure in
                self.showPopUp(isError: true, errorMessage: failure.errorMessage, delegate: self)
            }, onUserCancel: {
                self.showToast(message: "SDK is closed!")
            })
        } catch {
            let alert = UIAlertController(title: "Initialization Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc func cpqrcPayment() {
        guard let reference = self.paymentReference.text, !reference.isEmpty else {
            self.showPopUp(isError: true, errorMessage: "Payment reference must not be empty!", delegate: self)
            return
        }
        do {
            try CashBaba.shared.initialize(environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                                              languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn")

            let args = NavigationArgs(
                type: .CPQRC,
                wToken: self.wToken.text,
                languageCode: self.langSelectControl.selectedSegmentIndex == 0 ? "en" : "bn",
                environment: self.segmentedControl.selectedSegmentIndex == 0 ? .demo : .live,
                paymentReference: reference,
                clientId: self.clientID.text ?? "",
                clientSecret: self.clientSecret.text ?? "",
                phone: "01924278435"
            )
            SDKPresenter.present(from: self, args: args, onSuccess: { result in
                // handle success if needed
            }, onFailed: { failure in
                self.showPopUp(isError: true, errorMessage: failure.errorMessage, delegate: self)
            }, onUserCancel: {
                self.showToast(message: "SDK is closed!")
            })
        } catch {
            let alert = UIAlertController(title: "Initialization Failed", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        
    }
    
    private func showPopUp(isError: Bool, errorMessage: String, delegate: AlertDelegate?) {
        let title = isError ? "error".sslComLocalized() : "successful".sslComLocalized()
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            delegate?.alertDismissed(buttonTitle: action.title)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    class ScrollableView:UIView {
        let scrollView = UIScrollView()
        let contentView = UIView()
      
         init(axis: NSLayoutConstraint.Axis  = .vertical) {
            super.init(frame: .zero)
            self.addSubview(scrollView)
            scrollView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
            scrollView.addSubview(contentView)
            contentView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
             if(axis == .horizontal){
                 contentView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
             }else{
                 contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
             }
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.activeField == textField {
            self.activeField = nil
        }
    }
}

extension ViewController: AlertDelegate {
    func alertDismissed(buttonTitle: String?) {
        print("Dismissed: \(buttonTitle ?? "")")
    }
}

extension UIView{
    func addAnchorToSuperview(leading:CGFloat? = nil, trailing:CGFloat? = nil , top:CGFloat? = nil, bottom:CGFloat? = nil, heightMultiplier:CGFloat? = nil,widthMutiplier:CGFloat? = nil,centeredVertically : CGFloat? = nil, centeredHorizontally: CGFloat? = nil,heightWidthRatio:CGFloat? = nil )  {
        if  let superView = self.superview{
            self.translatesAutoresizingMaskIntoConstraints = false
            if let leading = leading {
                self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leading).isActive = true
            }
            if let trailing = trailing {
                self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: trailing).isActive = true
            }
            if let top = top{
                self.topAnchor.constraint(equalTo: superView.topAnchor, constant: top).isActive = true
            }
            if let bottom = bottom{
                self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: bottom).isActive = true
            }
            if let heightMultiplier = heightMultiplier{
                self.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: heightMultiplier).isActive = true
                if let heightWidthRatio = heightWidthRatio {
                    self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: heightWidthRatio).isActive = true
                }
            }
            if let widthMutiplier = widthMutiplier{
                self.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: widthMutiplier).isActive = true
                if let heightWidthRatio = heightWidthRatio {
                    self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: heightWidthRatio).isActive = true
                }
            }
            if let centeredVertically = centeredVertically{
                self.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant:centeredVertically ).isActive = true
            }
            if let centeredHorizontally = centeredHorizontally{
                self.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant:centeredHorizontally ).isActive = true
            }
            
        }
        
    }
}
