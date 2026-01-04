//
//  PINSetupVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

public class PINSetupVC: CBBaseViewController, CoordinatorAccessible {
    weak public var coordinator: Coordinating?
    private let verifyOTPType: VerifyOTPType
    private var ruleLoadFailCount: Int = 0
    
    public init(verifyOTPType: VerifyOTPType) {
        self.verifyOTPType = verifyOTPType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    internal lazy var pinView: PINSetupView = {
        let view = PINSetupView()
        return view
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        customTitle = "pin_setup".sslComLocalized()
        self.view.addSubview(pinView)
        pinView.addAnchorToSuperview(leading: 0, trailing: 0, top: appBarTotalHeight, bottom: 0)

        // Enable/disable submit based on input rules (5 digits and match)
        pinView.pinField.pinTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        pinView.confirmPinField.pinTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        setSubmitEnabled(false)

        // Submit action
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSubmit))
        pinView.submitButton.isUserInteractionEnabled = true
        pinView.submitButton.addGestureRecognizer(tap)
        
        // Load PIN rules on appear (retry logic similar to Android)
        getPinRules()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc private func textChanged() {
        let pin = pinView.pinField.pinTextField.text ?? ""
        let confirm = pinView.confirmPinField.pinTextField.text ?? ""
        let isValid = pin.count == 5 && confirm.count == 5 && pin == confirm && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: pin))
        setSubmitEnabled(isValid)
    }

    private func setSubmitEnabled(_ enabled: Bool) {
        pinView.submitButton.alpha = enabled ? 1.0 : 0.5
        pinView.submitButton.isUserInteractionEnabled = enabled
    }

    @objc private func onSubmit() {
        let pin = pinView.pinField.pinTextField.text ?? ""
        let confirm = pinView.confirmPinField.pinTextField.text ?? ""
        guard pin.count == 5, confirm.count == 5, pin == confirm else { return }
        CBProgressHUD.sharedInstance.startAnimation()
        switch verifyOTPType {
        case .setPin:
            CashBaba.shared.setPIN(pin: pin, confirmPin: confirm) { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success(let res):
                    // 200 → onSuccess with SDK close (no popup)
                    let model = OnSuccessModel.forSetPin(res)
                    self.coordinator?.closeSDKSuccessWithResult(model)
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        case .forgotPin:
            let identifier = CBSDKDataStorage.shared.forgetPinIdentifier
            CashBaba.shared.resetPIN(identifier: identifier, pin: pin, confirmPin: confirm) { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success(let res):
                    // 200 → onSuccess with SDK close (no popup)
                    let model = OnSuccessModel.forForgotPin(res)
                    self.coordinator?.closeSDKSuccessWithResult(model)
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        case .changePin:
            CBProgressHUD.sharedInstance.stopAnimation()
        case .cpqrcPayment:
            CBProgressHUD.sharedInstance.stopAnimation()
        }
    }
    
    // MARK: - PIN Rules (Android parity)
    private func getPinRules() {
        CashBaba.shared.getPinRules { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let res):
                if let mes = res.data?.validationMessages {
                    mes.forEach { item in
                        let label = SecurePINLabel()
                        label.translatesAutoresizingMaskIntoConstraints = false
                        label.setText((APIHandler.config.languageCode == "bn") ? "• " + (item.bangla ?? "") : "• " + (item.english ?? ""))
                        label.setTextColor(UIColor(hex: "#63666A", alpha: 1.0) ?? .black)
                        label.setFont(UIFont(name: FontManager.shared.fonts.kohinoorRegular, size: 12) ?? .systemFont(ofSize: 12))
                        label.numberOfLines = 2
                        self.pinView.instructionStack.addArrangedSubview(label)
                    }
                } else {
                    self.pinView.securePinTextContainer.isHidden = true
                }
                self.ruleLoadFailCount = 0
            case .failure:
                self.incrementRuleLoadFailCount()
            }
        }
    }

    private func incrementRuleLoadFailCount() {
        ruleLoadFailCount += 1
        if (1...2).contains(ruleLoadFailCount) {
            getPinRules()
        }
    }


    private func showErrorPopUp(isError: Bool, errorMessage: String) {
        let popup = CBErrorVC()
        popup.delegate = self
        popup.mView.errorTitle.text = isError ? "error".sslComLocalized() : "successful".sslComLocalized()
        popup.mView.errorMessage.text = errorMessage
        popup.modalPresentationStyle = .overCurrentContext
        self.present(popup, animated: true, completion: nil)
    }
}

extension PINSetupVC: CBPopUpDelegate, CBErrorDelegate {
    func vcDismissedWith(button: UIButton) {
        // Reset both PIN fields and disable the submit button
        pinView.pinField.pinTextField.text = ""
        pinView.confirmPinField.pinTextField.text = ""
        setSubmitEnabled(false)
        self.view.endEditing(true)
    }
    
    func popupDismissedWith(button: PopupButton, consent: Bool?, rating: Int?) {
        self.coordinatorCloseSDKSuccess()
    }
}
