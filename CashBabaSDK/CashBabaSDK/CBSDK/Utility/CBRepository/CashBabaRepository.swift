import Foundation

public protocol CashBabaRepository {
    // Auth
    func clientVerification(clientId: String, clientSecret: String, completion: @escaping (Result<ClientVerificationResponse, Error>) -> Void)

    // PIN
    func setPin(pin: String, confirmPin: String, completion: @escaping (Result<SetPinResponse, Error>) -> Void)
    func getSetPinOtp(completion: @escaping (Result<GetSetOtpResponse, Error>) -> Void)
    func verifySetPinOtp(otp: String, completion: @escaping (Result<BaseResponse, Error>) -> Void)
    func getPinRules(completion: @escaping (Result<PinValidationResponse, Error>) -> Void)
    func changePin(oldPin: String, pin: String, confirmPin: String, completion: @escaping (Result<ChangePinResponse, Error>) -> Void)
    func forgotPin(nationalId: String, dateOfBirth: String, completion: @escaping (Result<ForgetPinResponse, Error>) -> Void)
    func forgotPinOtpVerify(otp: String, completion: @escaping (Result<BaseResponse, Error>) -> Void)
    func forgotPinOtpResend(completion: @escaping (Result<BaseResponse, Error>) -> Void)
    func resetPin(identifier: String, pin: String, confirmPin: String, completion: @escaping (Result<BaseResponse, Error>) -> Void)

    // Transactions
    func confirmPinForTransfer(bankTokenNo: String, transactionAmount: String, pin: String, purpose: String, completion: @escaping (Result<TransferResponse, Error>) -> Void)
    func confirmPayment(paymentReference: String, pin: String, completion: @escaping (Result<PaymentResponse, Error>) -> Void)
    func confirmDistributorPayment(paymentReference: String, pin: String, completion: @escaping (Result<PaymentResponse, Error>) -> Void)

    // CPQRC
    func validateCpQrcPayment(paymentReference: String, completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void)
    func confirmCpqrcPayment(transactionId: String, otp: String, smileImage: Data?, blinkImage: Data?, completion: @escaping (Result<CpqrcPaymentConfirmResponse, Error>) -> Void)
    func verifyCpqrcPayment(paymentReference: String, completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void)
    func resendCpqrcPaymentOtp(transactionId: String, completion: @escaping (Result<BaseResponse, Error>) -> Void)
}

public final class CashBabaRepositoryImpl: CashBabaRepository {
    private let service = CBWebServiceHandler.shared

    public init() {}

    // Auth
    public func clientVerification(clientId: String, clientSecret: String, completion: @escaping (Result<ClientVerificationResponse, Error>) -> Void) {
        service.clientVerification(clientId: clientId, clientSecret: clientSecret, completion: completion)
    }

    // PIN
    public func setPin(pin: String, confirmPin: String, completion: @escaping (Result<SetPinResponse, Error>) -> Void) {
        service.setPin(pin: pin, confirmPin: confirmPin, completion: completion)
    }
    public func getSetPinOtp(completion: @escaping (Result<GetSetOtpResponse, Error>) -> Void) {
        service.getSetPinOtp(completion: completion)
    }
    public func verifySetPinOtp(otp: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        service.verifySetPinOtp(otp: otp, completion: completion)
    }
    public func getPinRules(completion: @escaping (Result<PinValidationResponse, Error>) -> Void) {
        service.getPinRules(completion: completion)
    }
    public func changePin(oldPin: String, pin: String, confirmPin: String, completion: @escaping (Result<ChangePinResponse, Error>) -> Void) {
        service.changePin(oldPin: oldPin, pin: pin, confirmPin: confirmPin, completion: completion)
    }
    public func forgotPin(nationalId: String, dateOfBirth: String, completion: @escaping (Result<ForgetPinResponse, Error>) -> Void) {
        service.forgotPin(nationalId: nationalId, dateOfBirth: dateOfBirth, completion: completion)
    }
    public func forgotPinOtpVerify(otp: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        service.forgotPinOtpVerify(otp: otp, completion: completion)
    }
    public func forgotPinOtpResend(completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        service.forgotPinOtpResend(completion: completion)
    }
    public func resetPin(identifier: String, pin: String, confirmPin: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        service.resetPin(identifier: identifier, pin: pin, confirmPin: confirmPin, completion: completion)
    }

    // Transactions
    public func confirmPinForTransfer(bankTokenNo: String, transactionAmount: String, pin: String, purpose: String, completion: @escaping (Result<TransferResponse, Error>) -> Void) {
        service.confirmPinForTransfer(bankTokenNo: bankTokenNo, transactionAmount: transactionAmount, pin: pin, purpose: purpose, completion: completion)
    }
    public func confirmPayment(paymentReference: String, pin: String, completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        service.confirmPayment(paymentReference: paymentReference, pin: pin, completion: completion)
    }
    public func confirmDistributorPayment(paymentReference: String, pin: String, completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        service.confirmDistributorPayment(paymentReference: paymentReference, pin: pin, completion: completion)
    }

    // CPQRC
    public func validateCpQrcPayment(paymentReference: String, completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void) {
        service.validateCpQrcPayment(paymentReference: paymentReference, completion: completion)
    }
    public func confirmCpqrcPayment(transactionId: String, otp: String, smileImage: Data?, blinkImage: Data?, completion: @escaping (Result<CpqrcPaymentConfirmResponse, Error>) -> Void) {
        service.confirmCpqrcPayment(transactionId: transactionId, otp: otp, smileImage: smileImage, blinkImage: blinkImage, completion: completion)
    }
    public func verifyCpqrcPayment(paymentReference: String, completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void) {
        service.verifyCpqrcPayment(paymentReference: paymentReference, completion: completion)
    }
    public func resendCpqrcPaymentOtp(transactionId: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        service.resendCpqrcPaymentOtp(transactionId: transactionId, completion: completion)
    }
}
