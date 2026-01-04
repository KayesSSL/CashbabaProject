//
//  ChangePINVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

public class ChangePINVC: CBBaseViewController, CoordinatorAccessible {
    weak public var coordinator: Coordinating?

    internal lazy var changePinView: CBChangePinView = {
        let view = CBChangePinView()
        return view
    }()

    private var ruleLoadFailCount: Int = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
        customTitle = "change_pin".sslComLocalized()
        self.view.addSubview(changePinView)
        changePinView.addAnchorToSuperview(leading: 0, trailing: 0, top: appBarTotalHeight, bottom: 0)

        // Input change listeners to toggle submit enable
        changePinView.oldPinField.pinTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        changePinView.enterPinField.pinTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        changePinView.confirmPinField.pinTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        setSubmitEnabled(false)

        // Submit tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSubmit))
        changePinView.submitButton.isUserInteractionEnabled = true
        changePinView.submitButton.addGestureRecognizer(tap)

        // Load PIN rules (retry like Android)
        getPinRules()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Input Handling
    @objc private func textChanged() {
        let old = changePinView.oldPinField.pinTextField.text ?? ""
        let pin = changePinView.enterPinField.pinTextField.text ?? ""
        let confirm = changePinView.confirmPinField.pinTextField.text ?? ""
        let validNew = pin.count == 5 && confirm.count == 5 && pin == confirm && isDigits(pin)
        let enabled = validNew && !old.isEmpty
        setSubmitEnabled(enabled)
    }

    private func isDigits(_ s: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: s))
    }

    private func setSubmitEnabled(_ enabled: Bool) {
        changePinView.submitButton.alpha = enabled ? 1.0 : 0.5
        changePinView.submitButton.isUserInteractionEnabled = enabled
    }

    // MARK: - Submit
    @objc private func onSubmit() {
        let old = changePinView.oldPinField.pinTextField.text ?? ""
        let pin = changePinView.enterPinField.pinTextField.text ?? ""
        let confirm = changePinView.confirmPinField.pinTextField.text ?? ""
        guard !old.isEmpty, pin.count == 5, confirm.count == 5, pin == confirm, isDigits(pin) else { return }

        CBProgressHUD.sharedInstance.startAnimation()
        CashBaba.shared.changePIN(oldPin: old, pin: pin, confirmPin: confirm) { [weak self] result in
            guard let self = self else { return }
            CBProgressHUD.sharedInstance.stopAnimation()
            switch result {
            case .success(let response):
                // Option B: No popup; immediately close SDK with success payload
                let model = OnSuccessModel.forChangePin(response)
                self.coordinator?.closeSDKSuccessWithResult(model)
            case .failure(let err):
                self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
            }
        }
    }

    // MARK: - Pin Rules
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
                        self.changePinView.securePinTextContainer.addArrangedSubview(label)
                    }
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

    // MARK: - Popups (errors only)

    private func showErrorPopUp(isError: Bool, errorMessage: String) {
        let popup = CBErrorVC()
        popup.delegate = self
        popup.mView.errorTitle.text = isError ? "error".sslComLocalized() : "successful".sslComLocalized()
        popup.mView.errorMessage.text = errorMessage
        popup.modalPresentationStyle = .overCurrentContext
        self.present(popup, animated: true, completion: nil)
    }
}

extension ChangePINVC: CBErrorDelegate {
    func vcDismissedWith(button: UIButton) {
        // no-op
        self.changePinView.oldPinField.pinTextField.text = ""
        self.changePinView.enterPinField.pinTextField.text = ""
        self.changePinView.confirmPinField.pinTextField.text = ""
        self.textChanged()
    }
}
