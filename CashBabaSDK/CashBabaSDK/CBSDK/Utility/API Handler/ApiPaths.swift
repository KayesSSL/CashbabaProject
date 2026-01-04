import Foundation

enum ApiPaths {
    static let clientVerify = "v1/connect/token"
    static let setPin = "v1/profile/pinset" //"v1/MerchantProfile/PinSet"
    static let getSetPinOtp = "v1/profile/otpsend" //MerchantProfile/OTPSend
    static let verifySetPinOtp = "v1/profile/otpverify" //MerchantProfile/OTPVerify
    static let pinRules = "v1/profile/pinvalidationrules" //account/PinValidationRules
    static let changePin = "v1/profile/pinchange" //MerchantProfile/PinChange
    static let forgotPin = "v1/profile/forgetpin" //MerchantProfile/ForgetPIN
    static let forgotPinOtpVerify = "v1/profile/forgetpinotpverify" //MerchantProfile/ForgetPinOTPVerify
    static let forgotPinOtpResend = "v1/profile/forgetpinotpresend" //MerchantProfile/ForgetPinOtpResend
    static let resetPin = "v1/profile/resetpin" //MerchantProfile/ResetPIN
    static let transfer = "v1/Transaction/WithdrawMoneyToBank"
    static let payment = "v1/transaction/PaymentConfirm"
    static let distributorPayment = "v1/transaction/MerchantDistributorPaymentConfirm"
    static func validateCpqrc(_ ref: String) -> String { "v1/transaction/CPQRCPaymentValidation/\(ref)" }
    static let confirmCpqrc = "v1/transaction/CPQRCPaymentConfirm"
    static func verifyCpqrc(_ ref: String) -> String { "v1/transaction/CPQRCPaymentStatus/\(ref)" }
    static let resendCpqrcOtp = "v1/transaction/ResendTransactionOTP"
}
