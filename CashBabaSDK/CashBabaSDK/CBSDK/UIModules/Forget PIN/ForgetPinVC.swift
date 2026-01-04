//
//  ForgetPinVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/14/25.
//

import UIKit

public class ForgetPinVC: CBBaseViewController, CoordinatorAccessible {
    weak public var coordinator: Coordinating?

    internal lazy var forgetPinView: ForgetPinView = {
        let view = ForgetPinView()
        return view
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        customTitle = "forgot_pin".sslComLocalized()
        self.view.addSubview(forgetPinView)
        forgetPinView.addAnchorToSuperview(leading: 0, trailing: 0, top: appBarTotalHeight, bottom: 0)

        // Inputs
        forgetPinView.nidField.pinTextField.keyboardType = .numberPad
        forgetPinView.nidField.pinTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        // Observe DOB change as well
        forgetPinView.onDOBChanged = { [weak self] in
            self?.textChanged()
        }

        // Submit
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSubmit))
        forgetPinView.submitButton.isUserInteractionEnabled = true
        forgetPinView.submitButton.addGestureRecognizer(tap)

        setSubmitEnabled(false)
    }

    // Enable when last 4 NID digits and DOB selected
    @objc private func textChanged() {
        let nid = forgetPinView.nidField.pinTextField.text ?? ""
        let dobDisplay = forgetPinView.confirmPinField.pinTextLabel.text ?? ""
        let enabled = (nid.count == 4 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: nid)) && !dobDisplay.isEmpty)
        setSubmitEnabled(enabled)
    }

    private func setSubmitEnabled(_ enabled: Bool) {
        forgetPinView.submitButton.alpha = enabled ? 1.0 : 0.5
        forgetPinView.submitButton.isUserInteractionEnabled = enabled
    }

    // MARK: - Submit
    @objc private func onSubmit() {
        let nid = forgetPinView.nidField.pinTextField.text ?? ""
        let dobDisplay = forgetPinView.confirmPinField.pinTextLabel.text ?? ""
        guard nid.count == 4, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: nid)), !dobDisplay.isEmpty else { return }

        // Convert display "dd MMMM yyyy" to API format "yyyy-MM-dd"
        let apiDob = CBSDKManager.sharedInstance.date(toTimestamp: dobDisplay, dateFormate: "dd MMMM yyyy", expectedDateFormate: "yyyy-MM-dd")

        CBProgressHUD.sharedInstance.startAnimation()
        CashBaba.shared.forgotPIN(nationalId: nid, dateOfBirth: apiDob) { [weak self] result in
            guard let self = self else { return }
            CBProgressHUD.sharedInstance.stopAnimation()
            switch result {
            case .success:
                // Navigate to Verify OTP for Forgot PIN
                self.coordinator?.navigate(to: .verifyOTP(verifyOTPType: .forgotPin), animated: true)
            case .failure(let err):
                self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
            }
        }
    }

    // MARK: - Error popup for non-fatal errors
    private func showErrorPopUp(isError: Bool, errorMessage: String) {
        let popup = CBErrorVC()
        popup.delegate = self
        popup.mView.errorTitle.text = isError ? "error".sslComLocalized() : "successful".sslComLocalized()
        popup.mView.errorMessage.text = errorMessage
        popup.modalPresentationStyle = .overCurrentContext
        self.present(popup, animated: true, completion: nil)
    }
}

extension ForgetPinVC: CBErrorDelegate {
    func vcDismissedWith(button: UIButton) {
        self.forgetPinView.nidField.pinTextField.text = ""
        self.forgetPinView.confirmPinField.pinTextLabel.text = ""
        self.textChanged()
    }
}
