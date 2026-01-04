//
//  OTPVerificationVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import UIKit

public class OTPVerificationVC: CBBaseViewController, CoordinatorAccessible {
    weak public var coordinator: Coordinating?
    private let verifyOTPType: VerifyOTPType
    private var inputOtp: String = ""
    private var isResendEnabled: Bool = false
    
    public init(verifyOTPType: VerifyOTPType) {
        self.verifyOTPType = verifyOTPType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private var resendOTPTimer: Timer?
    
    private var otpTimeOutInSeconds = 2 * 60
    private var timeOutTimeAppWentBackground: CFTimeInterval?
    var keyboardObserver: KeyboardObserver!
    
    internal lazy var otpVerificationView: OTPVerificationView = {
        let view = OTPVerificationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.customOTPTextField.dpOTPViewDelegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(verified))
        view.verifyContainer.addGestureRecognizer(tap)
        // Resend tap
        let resendTap = UITapGestureRecognizer(target: self, action: #selector(resendTapped))
        view.timerText.addGestureRecognizer(resendTap)
        return view
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(otpAppMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otpAppMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.view.addSubview(otpVerificationView)
        otpVerificationView.addAnchorToSuperview(leading: 0, trailing: 0, top: appBarTotalHeight, bottom: 0)

        keyboardObserver = KeyboardObserver(for: self)
        customTitle = "otp_verification".sslComLocalized()
        // Show phone
        if let phone = CBSDKDataStorage.shared.navigationArgs?.phone, !phone.isEmpty {
            otpVerificationView.verifySubTitle.text = String(format: "sent_sms_to_phone".sslComLocalized(), CBSDKLanguageHandler.sharedInstance.getLocalizedDigits(phone) ?? "")
        }
        if otpVerificationView.customOTPTextField.validate() {
            // validation logic
        }
        _ = otpVerificationView.customOTPTextField.resignFirstResponder()

        // Android parity: for SET_PIN, request OTP then start countdown
        if verifyOTPType == .setPin {
            CBProgressHUD.sharedInstance.startAnimation()
            CashBaba.shared.getSetPinOTP { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    if self.resendOTPTimer == nil { self.startOTPSessionTimer() }
                    self.isResendEnabled = false
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        } else if verifyOTPType == .forgotPin {
            if resendOTPTimer == nil { startOTPSessionTimer() }
            isResendEnabled = false
        } else if verifyOTPType == .cpqrcPayment {
            // For CPQRC, validation already happened in coordinator; just start timer UI
            if resendOTPTimer == nil { startOTPSessionTimer() }
            isResendEnabled = false
        }
        updateVerifyEnabled()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.add()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
//    func displayAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
//        guard presentedViewController == nil else { return }
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        actions?.forEach { action in
//            alertController.addAction(action)
//        }
//        present(alertController, animated: true)
//    }
//
//    public func didUserFinishEnter(the code: String) {
//        let doneAction = UIAlertAction(title: "Done", style: .default)
//        let message = "Success"
//        displayAlert(with: "Verify Result", message: message, actions: [doneAction])
//    }
    
    @objc public func verified() {
        // Verify OTP based on type, then navigate to PIN setup
        guard inputOtp.count == 6 else { return }
        CBProgressHUD.sharedInstance.startAnimation()
        switch verifyOTPType {
        case .setPin:
            CashBaba.shared.verifySetPinOTP(otp: inputOtp) { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    self.coordinator?.navigate(to: .pinSetup(verifyOTPType: .setPin), animated: true)
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        case .forgotPin:
            CashBaba.shared.forgotPinOTPVerify(otp: inputOtp) { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    self.coordinator?.navigate(to: .pinSetup(verifyOTPType: .forgotPin), animated: true)
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        case .changePin:
            // Not used for change pin in Android here; default back
            CBProgressHUD.sharedInstance.stopAnimation()
        case .cpqrcPayment:
            guard let txnId = CBSDKDataStorage.shared.cpqrcValidationData?.transactionId, !txnId.isEmpty else {
                CBProgressHUD.sharedInstance.stopAnimation()
                showErrorPopUp(isError: true, errorMessage: "Missing transaction id")
                return
            }
            let smilePath = CBSDKDataStorage.shared.smileFacePath
            let blinkPath = CBSDKDataStorage.shared.blinkFacePath
            let smileData = dataFrom(path: smilePath)
            let blinkData = dataFrom(path: blinkPath)
            CashBaba.shared.cpqrcConfirm(transactionId: txnId, otp: inputOtp, smileImage: smileData, blinkImage: blinkData) { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    // After confirm success, optionally verify status, then close with success or continue as per product flow
                    if let paymentRef = CBSDKDataStorage.shared.navigationArgs?.paymentReference {
                        CashBaba.shared.cpqrcVerify(paymentReference: paymentRef) { _ in }
                    }
                    // For parity, close SDK success or navigate accordingly; here we close to host with onSuccess via coordinator if needed
                    self.coordinator?.closeSDKSuccess()
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        }
    }
    
    private func dataFrom(path: String?) -> Data? {
        guard let p = path, !p.isEmpty else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: p))
    }

    @objc private func resendTapped() {
        guard isResendEnabled else { return }
        // Clear current OTP
        inputOtp = ""
        otpVerificationView.customOTPTextField.text = ""
        updateVerifyEnabled()
        switch verifyOTPType {
        case .setPin:
            CBProgressHUD.sharedInstance.startAnimation()
            CashBaba.shared.getSetPinOTP { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    self.resetAndStartTimer()
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        case .forgotPin:
            CBProgressHUD.sharedInstance.startAnimation()
            CashBaba.shared.forgotPinOTPResend { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    self.resetAndStartTimer()
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        case .changePin:
            break
        case .cpqrcPayment:
            guard let txnId = CBSDKDataStorage.shared.cpqrcValidationData?.transactionId, !txnId.isEmpty else {
                showErrorPopUp(isError: true, errorMessage: "Missing transaction id")
                return
            }
            CBProgressHUD.sharedInstance.startAnimation()
            CashBaba.shared.cpqrcResendOtp(transactionId: txnId) { [weak self] result in
                guard let self = self else { return }
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    self.resetAndStartTimer()
                case .failure(let err):
                    self.showErrorPopUp(isError: true, errorMessage: err.localizedDescription)
                }
            }
        }
    }

    private func resetAndStartTimer() {
        isResendEnabled = false
        otpTimeOutInSeconds = 2 * 60
        resendOTPTimer?.invalidate()
        resendOTPTimer = nil
        startOTPSessionTimer()
    }

    private func updateVerifyEnabled() {
        let enabled = inputOtp.count == 6
        otpVerificationView.verifyContainer.alpha = enabled ? 1.0 : 0.5
        otpVerificationView.verifyContainer.isUserInteractionEnabled = enabled
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

extension OTPVerificationVC: CBErrorDelegate {
    
    func vcDismissedWith(button: UIButton) {
        // no-op for error popup dismiss
        otpVerificationView.customOTPTextField.text = ""
        inputOtp = ""
        updateVerifyEnabled()
    }
}

//MARK: - SessionTimerLogic

extension OTPVerificationVC {
    private func startOTPSessionTimer(){
        resendOTPTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.otpUpdateTimer(_:))), userInfo: nil, repeats: true)
    }
    @objc private func otpUpdateTimer(_ timer: Timer?) {
        if otpTimeOutInSeconds < 0 {
            if self.resendOTPTimer != nil{
                // mView.timeOutLabel.text = "\(formattedTimeStringFrom(timeInterval: TimeInterval(timeOutInSeconds)))"
                // showErrorMessageAndDismissSDK(message: "transaction_timeout_message_text".sslComLocalized())
                timer?.invalidate()
                isResendEnabled = true
                UIView.transition(with: otpVerificationView.timerText, duration: 0.25, options: .beginFromCurrentState, animations: {
                    self.otpVerificationView.sendCodeAgainText.text = "did_not_get_code".sslComLocalized()
                    self.otpVerificationView.timerText.text = "resend".sslComLocalized()
                    self.otpVerificationView.timerText.textColor = UIColor(hex: "#007AFF", alpha: 1.0)
                })
            }
        } else {
            UIView.transition(with: otpVerificationView.timerText, duration: 0.50, options: .beginFromCurrentState, animations: {
                self.otpVerificationView.sendCodeAgainText.text = "send_code_again".sslComLocalized()
                self.otpVerificationView.timerText.text = CBSDKLanguageHandler.sharedInstance.getLocalizedDigits(self.formattedTimeStringFrom(timeInterval: TimeInterval(self.otpTimeOutInSeconds))) ?? ""
                self.otpVerificationView.timerText.textColor = UIColor(hex: "#F87005", alpha: 1.0)
            })
            otpTimeOutInSeconds -= 1
        }
    }
    @objc func otpAppMovedToBackground() {
        timeOutTimeAppWentBackground = CACurrentMediaTime()
    }
    
    @objc func otpAppMovedToForeground() {
        otpTimeOutInSeconds -= Int(CACurrentMediaTime() - (timeOutTimeAppWentBackground ?? 0.0))
    }
}

extension OTPVerificationVC: KeyboardObserverProtocol{
    func keyboardWillShow(with height: CGFloat) {
//        mView.heightContraint?.constant = height
    }
    
    func keybaordWillHide() {
//        mView.heightContraint?.constant = 0
    }
}


extension OTPVerificationVC : DPOTPViewDelegate {
    public func dpOTPViewAddText(_ text: String, at position: Int) {
        inputOtp = otpVerificationView.customOTPTextField.text ?? ""
        updateVerifyEnabled()
    }
    
    public func dpOTPViewRemoveText(_ text: String, at position: Int) {
        inputOtp = otpVerificationView.customOTPTextField.text ?? ""
        updateVerifyEnabled()
    }
    
    public func dpOTPViewChangePositionAt(_ position: Int) {
        // no-op
    }
    public func dpOTPViewBecomeFirstResponder() {
        
    }
    public func dpOTPViewResignFirstResponder() {
        
    }
}
