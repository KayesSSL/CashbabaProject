//
//  ConfirmPINVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 11/3/25.
//

import UIKit

public class ConfirmPINVC: CBBaseViewController, CoordinatorAccessible {
    weak public var coordinator: Coordinating?
    private var inputPin: String = ""

    internal lazy var confirmPinView: ConfirmPINView = {
        let view = ConfirmPINView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        customTitle = "confirm_pin".sslComLocalized()
        self.view.addSubview(confirmPinView)
        confirmPinView.addAnchorToSuperview(leading: 0, trailing: 0, top: appBarTotalHeight, bottom: 0)

        // Set DPOTPView delegate and initialize state
        confirmPinView.customOTPTextField.dpOTPViewDelegate = self
        updateSubmitEnabled()

        let tap = UITapGestureRecognizer(target: self, action: #selector(onSubmit))
        confirmPinView.submitContainer.isUserInteractionEnabled = true
        confirmPinView.submitContainer.addGestureRecognizer(tap)
    }

    private func updateSubmitEnabled() {
        let enabled = inputPin.count == 5
        confirmPinView.submitContainer.alpha = enabled ? 1.0 : 0.5
        confirmPinView.submitContainer.isUserInteractionEnabled = enabled
    }

    @objc private func onSubmit() {
        let pin = inputPin
        guard pin.count == 5 else { return }

        guard let args = CBSDKDataStorage.shared.navigationArgs else { return }

        CBProgressHUD.sharedInstance.startAnimation()
        switch args.type {
        case .TRANSFER_MONEY:
            guard let info = args.transferInfo else {
                showErrorPopUp(isError: true, errorMessage: "transfer_info_not_found".sslComLocalized())
                CBProgressHUD.sharedInstance.stopAnimation()
                return
            }
            CashBabaRepositoryImpl().confirmPinForTransfer(
                bankTokenNo: info.bankTokenNo,
                transactionAmount: info.transactionAmount,
                pin: pin,
                purpose: info.purpose
            ) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    CBProgressHUD.sharedInstance.stopAnimation()
                    switch result {
                    case .success(let res):
                        let model = OnSuccessModel.forTransfer(res)
                        self.coordinator?.closeSDKSuccessWithResult(model)
                    case .failure(let err):
                        self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                    }
                }
            }
        case .PAYMENT:
            guard let reference = args.paymentReference, !reference.isEmpty else {
                showErrorPopUp(isError: true, errorMessage: "payment_reference_missing".sslComLocalized())
                CBProgressHUD.sharedInstance.stopAnimation()
                return
            }
            CashBabaRepositoryImpl().confirmPayment(paymentReference: reference, pin: pin) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    CBProgressHUD.sharedInstance.stopAnimation()
                    switch result {
                    case .success(let res):
                        let model = OnSuccessModel.forPayment(res)
                        self.coordinator?.closeSDKSuccessWithResult(model)
                    case .failure(let err):
                        self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                    }
                }
            }
        case .DISTRIBUTOR_PAYMENT:
            guard let reference = args.paymentReference, !reference.isEmpty else {
                showErrorPopUp(isError: true, errorMessage: "payment_reference_missing".sslComLocalized())
                CBProgressHUD.sharedInstance.stopAnimation()
                return
            }
            CashBabaRepositoryImpl().confirmDistributorPayment(paymentReference: reference, pin: pin) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    CBProgressHUD.sharedInstance.stopAnimation()
                    switch result {
                    case .success(let res):
                        let model = OnSuccessModel.forDistributorPayment(res)
                        self.coordinator?.closeSDKSuccessWithResult(model)
                    case .failure(let err):
                        self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                    }
                }
            }
        default:
            CBProgressHUD.sharedInstance.stopAnimation()
            break
        }
    }

    private func showErrorPopUp(isError: Bool, errorMessage: String) {
        DispatchQueue.main.async {
            let popup = CBErrorVC()
            popup.delegate = self
            popup.mView.errorTitle.text = isError ? "error".sslComLocalized() : "successful".sslComLocalized()
            popup.mView.errorMessage.text = errorMessage
            popup.modalPresentationStyle = .overCurrentContext
            self.definesPresentationContext = true
            self.present(popup, animated: true, completion: nil)
        }
    }
}

extension ConfirmPINVC: CBErrorDelegate {
    func vcDismissedWith(button: UIButton) {
        // Clear the PIN input and disable submit button
        confirmPinView.customOTPTextField.text = ""
        inputPin = ""
        updateSubmitEnabled()
    }
}

extension ConfirmPINVC: DPOTPViewDelegate {
    public func dpOTPViewAddText(_ text: String, at position: Int) {
        inputPin = confirmPinView.customOTPTextField.text ?? ""
        updateSubmitEnabled()
    }
    public func dpOTPViewRemoveText(_ text: String, at position: Int) {
        inputPin = confirmPinView.customOTPTextField.text ?? ""
        updateSubmitEnabled()
    }
    public func dpOTPViewChangePositionAt(_ position: Int) {}
    public func dpOTPViewBecomeFirstResponder() {}
    public func dpOTPViewResignFirstResponder() {}
}

