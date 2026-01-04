//
//  CashBabaSDK.swift
//  CashBabaSDK
//
//  Created by Imrul Kayes on 1/4/26.
//

import Foundation

public final class CashBaba {
    public static let shared = CashBaba()
    private init() {}

    // Repository abstraction (mirrors Android's repository usage)
    private let repo: CashBabaRepository = CashBabaRepositoryImpl()
    private var expiryTimer: Timer?
    private var tickObserver: NSObjectProtocol?

    // Callback channel (Android parity using OnSuccessModel/OnFailedModel)
    public var onSuccess: ((OnSuccessModel) -> Void)?
    public var onFailed: ((OnFailedModel) -> Void)?
    public var onUserCancel: (() -> Void)?

    public func setCallbacks(onSuccess: ((OnSuccessModel) -> Void)? = nil,
                             onFailed: ((OnFailedModel) -> Void)? = nil,
                             onUserCancel: (() -> Void)? = nil) {
        self.onSuccess = onSuccess
        self.onFailed = onFailed
        self.onUserCancel = onUserCancel
    }

    // MARK: - Initialization / Configuration

    public func initialize(environment: Environment,
                           languageCode: String,
                           scope: String? = nil,
                           wToken: String? = nil,
                           derData: Data? = nil) throws {
        APIHandler.config.environment = environment
        APIHandler.config.languageCode = languageCode
        APIHandler.config.scope = scope
        APIHandler.config.wToken = wToken
        if let pem = derData { try Encryptor.shared.initialize(pemData: pem) }
    }

    // Convenience: load PEM by resource name from bundle
    public func initialize(
        environment: Environment,
        languageCode: String,
        scope: String? = nil,
        wToken: String? = nil
    ) throws {
        APIHandler.config.environment = environment
        APIHandler.config.languageCode = languageCode
        APIHandler.config.scope = scope
        APIHandler.config.wToken = wToken

        // Try to locate CBSDKResources.bundle - handles both framework and CocoaPods scenarios
        let frameworkBundle = Bundle(for: CashBaba.self)
        var resourceBundle: Bundle?
        
        // Scenario 1: Direct framework bundle (Xcode project)
        if let bundleURL = frameworkBundle.url(forResource: "CBSDKResources", withExtension: "bundle") {
            resourceBundle = Bundle(url: bundleURL)
        }
        
        // Scenario 2: CocoaPods resource_bundles - bundle is inside the pod's resource bundle
        if resourceBundle == nil {
            // CocoaPods creates the bundle at: CashBabaSDK.framework/CBSDKResources.bundle
            // or for development pods: Pods/CashBabaSDK/CBSDKResources.bundle
            let podBundleName = "CashBabaSDK"
            if let podBundleURL = frameworkBundle.url(forResource: podBundleName, withExtension: "bundle"),
               let podBundle = Bundle(url: podBundleURL),
               let resBundleURL = podBundle.url(forResource: "CBSDKResources", withExtension: "bundle") {
                resourceBundle = Bundle(url: resBundleURL)
            }
        }
        
        // Scenario 3: Try finding publickey.der directly in framework bundle (fallback)
        if resourceBundle == nil {
            if frameworkBundle.url(forResource: "publickey", withExtension: "der") != nil {
                resourceBundle = frameworkBundle
            }
        }
        
        guard let bundle = resourceBundle else {
            throw SDKError.decode("CBSDKResources.bundle not found in framework")
        }

        // Load publickey.der from the resource bundle
        guard let derURL = bundle.url(forResource: "publickey", withExtension: "der"),
              let derData = try? Data(contentsOf: derURL) else {
            throw SDKError.decode("publickey.der not found or unreadable")
        }
        
        try initialize(environment: environment, languageCode: languageCode, scope: scope, wToken: wToken, derData: derData)
    }

    public func setScope(_ scope: String) {
        APIHandler.config.scope = scope
    }

    public func setWToken(_ token: String?) {
        APIHandler.config.wToken = token
    }

    // MARK: - Authentication

    public func clientVerification(clientId: String,
                                   clientSecret: String,
                                   completion: @escaping (Result<ClientVerificationResponse, Error>) -> Void) {
        repo.clientVerification(clientId: clientId, clientSecret: clientSecret) { result in
            switch result {
            case .success(let res):
                SessionStore.shared.updateToken(accessToken: res.accessToken, expiresInSeconds: res.expiresIn)
                let secs = (res.expiresIn ?? 60)
                print("[ClientVerification] expiresIn=\(res.expiresIn ?? -1) -> starting timer with seconds=\(secs)")
                SessionTimerManager.shared.start(with: secs)
                print("[ClientVerification] timer running=\(SessionTimerManager.shared.isTimerRunning) remaining=\(SessionTimerManager.shared.remainingSeconds)")
                self.startExpiryTimer(seconds: res.expiresIn)
                self.observeSessionTicks()
                DispatchQueue.main.async { completion(.success(res)) }
            case .failure(let err):
                DispatchQueue.main.async { completion(.failure(err)) }
            }
        }
    }

    private func startExpiryTimer(seconds: Int?) {
        expiryTimer?.invalidate()
        guard let s = seconds, s > 0 else { return }
        expiryTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(s), repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.onFailed?(OnFailedModel(errorMessage: "session_expired".sslComLocalized()))
            // Any additional closure of UI can be handled by the host using this callback
        }
        RunLoop.current.add(expiryTimer!, forMode: .common)
    }

    private func observeSessionTicks() {
        // Remove previous observer if any
        if let obs = tickObserver { NotificationCenter.default.removeObserver(obs) }
        tickObserver = NotificationCenter.default.addObserver(forName: .sessionTimerDidTick, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            // Only fail when a timer is actually running and reached 0
            if SessionTimerManager.shared.isTimerRunning && SessionTimerManager.shared.remainingSeconds <= 0 {
                self.onFailed?(OnFailedModel(errorMessage: "session_expired".sslComLocalized()))
                if let obs = self.tickObserver { NotificationCenter.default.removeObserver(obs) }
                self.tickObserver = nil
            }
        }
    }

    // MARK: - Session reset (to avoid immediate timeout on re-present)
    public func resetSession() {
        expiryTimer?.invalidate()
        expiryTimer = nil
        if let obs = tickObserver { NotificationCenter.default.removeObserver(obs) }
        tickObserver = nil
        // Ensure shared session timer is fully stopped
        SessionTimerManager.shared.stop()
    }

    // MARK: - Helpers (Android parity)
    public func closeSdkOnFailed(_ message: String) {
        onFailed?(OnFailedModel(errorMessage: message))
    }

    // MARK: - PIN Management

    public func setPIN(pin: String,
                       confirmPin: String,
                       completion: @escaping (Result<SetPinResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.setPin(pin: pin, confirmPin: confirmPin) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func getSetPinOTP(completion: @escaping (Result<GetSetOtpResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.getSetPinOtp { result in DispatchQueue.main.async { completion(result) } }
    }

    public func verifySetPinOTP(otp: String,
                                completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.verifySetPinOtp(otp: otp) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func getPinRules(completion: @escaping (Result<PinValidationResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.getPinRules { result in DispatchQueue.main.async { completion(result) } }
    }

    public func changePIN(oldPin: String,
                          pin: String,
                          confirmPin: String,
                          completion: @escaping (Result<ChangePinResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.changePin(oldPin: oldPin, pin: pin, confirmPin: confirmPin) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func forgotPIN(nationalId: String,
                          dateOfBirth: String,
                          completion: @escaping (Result<ForgetPinResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.forgotPin(nationalId: nationalId, dateOfBirth: dateOfBirth) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func forgotPinOTPVerify(otp: String,
                                   completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.forgotPinOtpVerify(otp: otp) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func forgotPinOTPResend(completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.forgotPinOtpResend { result in DispatchQueue.main.async { completion(result) } }
    }

    public func resetPIN(identifier: String,
                         pin: String,
                         confirmPin: String,
                         completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.config.scope = "PinManagement"
        repo.resetPin(identifier: identifier, pin: pin, confirmPin: confirmPin) { result in DispatchQueue.main.async { completion(result) } }
    }

    // MARK: - Transactions

    public func transferMoney(bankTokenNo: String,
                               transactionAmount: String,
                               pin: String,
                               purpose: String,
                               completion: @escaping (Result<TransferResponse, Error>) -> Void) {
        APIHandler.config.scope = "LinkBank"
        repo.confirmPinForTransfer(bankTokenNo: bankTokenNo, transactionAmount: transactionAmount, pin: pin, purpose: purpose) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func payment(paymentReference: String,
                        pin: String,
                        completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        APIHandler.config.scope = "Transaction"
        repo.confirmPayment(paymentReference: paymentReference, pin: pin) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func distributorPayment(paymentReference: String,
                                   pin: String,
                                   completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        APIHandler.config.scope = "Transaction"
        repo.confirmDistributorPayment(paymentReference: paymentReference, pin: pin) { result in DispatchQueue.main.async { completion(result) } }
    }

    // MARK: - CPQRC

    public func cpqrcValidate(paymentReference: String,
                               completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void) {
        APIHandler.config.scope = "Transaction"
        repo.validateCpQrcPayment(paymentReference: paymentReference) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func cpqrcConfirm(transactionId: String,
                              otp: String,
                              smileImage: Data? = nil,
                              blinkImage: Data? = nil,
                              completion: @escaping (Result<CpqrcPaymentConfirmResponse, Error>) -> Void) {
        APIHandler.config.scope = "Transaction"
        repo.confirmCpqrcPayment(transactionId: transactionId, otp: otp, smileImage: smileImage, blinkImage: blinkImage) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func cpqrcVerify(paymentReference: String,
                             completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void) {
        APIHandler.config.scope = "Transaction"
        repo.verifyCpqrcPayment(paymentReference: paymentReference) { result in DispatchQueue.main.async { completion(result) } }
    }

    public func cpqrcResendOtp(transactionId: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.config.scope = "Transaction"
        repo.resendCpqrcPaymentOtp(transactionId: transactionId) { result in DispatchQueue.main.async { completion(result) } }
    }
}

