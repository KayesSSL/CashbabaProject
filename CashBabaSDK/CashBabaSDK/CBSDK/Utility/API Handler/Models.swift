import Foundation

// MARK: - Common/Base

public struct BaseResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let details: String?
}

// MARK: - Client Verification

public struct ClientVerificationResponse: Codable {
    public let code: Int?
    public let accessToken: String?
    public let messages: [String]?
    public let tokenType: String?
    public let expiresIn: Int?
    public let details: String?

    enum CodingKeys: String, CodingKey {
        case code
        case accessToken = "access_token"
        case messages
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case details
    }
}

// MARK: - PIN Responses

public struct SetPinResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let details: String?
}

public struct ChangePinResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let details: String?
}

public struct ForgetPinResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let details: String?
}

public struct ForgotPinVerifyResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let data: ForgetPinData?
    public let details: String?
}

public struct ForgetPinData: Codable {
    public let identifier: String?
}

public struct GetSetOtpResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let data: SetPinOtpData?
    public let details: String?
}

public struct SetPinOtpData: Codable {
    public let otpExpireAt: String?
}

public struct PinValidationResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let data: PinData?
    public let details: String?
}

public struct PinData: Codable {
    public let validationMessages: [ValidationMessage]?
}

public struct ValidationMessage: Codable {
    public let english: String?
    public let bangla: String?
}

// MARK: - Transaction/Payment Responses

public struct TransferResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let data: TransferData?
    public let details: String?
}

public struct TransferData: Codable {
    public let responseCode: Int?
    public let message: String?
    public let transactionId: String?
    public let otpExpire: String?
    public let isOtpRequired: Bool?
    public let isPinRequired: Bool?
    public let status: Int?
    public let mfaType: String?
}

public struct PaymentResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let data: PaymentData?
    public let details: String?
}

public struct PaymentData: Codable {
    public let responseCode: Int?
    public let message: String?
    public let transactionID: String?
    public let paymentReference: String?
    public let transactionCurrencyCode: String?
    public let transactionAmount: Double?
    public let feeAmount: Double?
    public let totalAmount: Double?
    public let availableBalance: Double?
    public let transactionStatus: String?
    public let isOtpRequired: Bool?
    public let isPinRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case responseCode
        case message
        case transactionID = "transactionId"
        case paymentReference
        case transactionCurrencyCode
        case transactionAmount
        case feeAmount
        case totalAmount
        case availableBalance
        case transactionStatus
        case isOtpRequired
        case isPinRequired
    }
}

// MARK: - CPQRC

public struct CpqrcValidationResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let data: CpqrcValidationData?
    public let details: String?
}

public struct CpqrcValidationData: Codable {
    public let responseCode: Int?
    public let message: String?
    public let transactionId: String?
    public let otpExpire: String?
    public let isOtpRequired: Bool?
    public let isPinRequired: Bool?
    public let isFaceVerificationRequired: Bool?
    public let status: String?
    public let mfaType: String?
    public let otpExpirySeconds: Int?
}

public struct CpqrcPaymentConfirmResponse: Codable {
    public let code: Int?
    public let messages: [String]?
    public let data: CpqrcPaymentConfirmData?
    public let details: String?
}

public struct CpqrcPaymentConfirmData: Codable {
    public let responseCode: Int?
    public let message: String?
    public let transactionId: String?
    public let otpExpire: String?
    public let isOtpRequired: Bool?
    public let isPinRequired: Bool?
    public let isFaceVerificationRequired: Bool?
    public let status: Int?
    public let mfaType: String?
}

// MARK: - Navigation and Misc Models

public enum MethodTypes: String, Codable {
    case SET_PIN
    case CHANGE_PIN
    case FORGET_PIN
    case TRANSFER_MONEY
    case PAYMENT
    case DISTRIBUTOR_PAYMENT
    case CPQRC
}

public enum LanguageCode: String, Codable { case EN, BN }

public struct NavigationArguments: Codable {
    public let type: MethodTypes
    public let wToken: String
    public let phone: String
    public let clientId: String
    public let clientSecret: String
    public let scope: String
    public let languageCode: LanguageCode
    public let transferInfo: TransferInfo?
    public let paymentReference: String?
}

public struct TransferInfo: Codable {
    public let bankTokenNo: String
    public let transactionAmount: String
    public let purpose: String

    public init(bankTokenNo: String, transactionAmount: String, purpose: String) {
        self.bankTokenNo = bankTokenNo
        self.transactionAmount = transactionAmount
        self.purpose = purpose
    }

    public func asFormFields() -> [String: Any] {
        [
            "BankTokenNo": bankTokenNo,
            "TransactionAmount": transactionAmount,
            "Purpose": purpose
        ]
    }
}

public struct OnFailedModel: Codable { public let errorMessage: String }

public struct OnSuccessModel: Codable {
    public let setPinResponse: SetPinResponse?
    public let changePinResponse: ChangePinResponse?
    public let forgetPinResponse: ForgetPinResponse?
    public let transferResponse: TransferResponse?
    public let paymentResponse: PaymentResponse?
    public let distributorPaymentResponse: PaymentResponse?
    public let cpqrcResponse: CpqrcValidationResponse?
}

public extension OnSuccessModel {
    static func forChangePin(_ response: ChangePinResponse) -> OnSuccessModel {
        // Use internal memberwise init within module to construct payload
        return OnSuccessModel(
            setPinResponse: nil,
            changePinResponse: response,
            forgetPinResponse: nil,
            transferResponse: nil,
            paymentResponse: nil,
            distributorPaymentResponse: nil,
            cpqrcResponse: nil
        )
    }
    
    static func forSetPin(_ response: SetPinResponse) -> OnSuccessModel {
        return OnSuccessModel(
            setPinResponse: response,
            changePinResponse: nil,
            forgetPinResponse: nil,
            transferResponse: nil,
            paymentResponse: nil,
            distributorPaymentResponse: nil,
            cpqrcResponse: nil
        )
    }

    static func forTransfer(_ response: TransferResponse) -> OnSuccessModel {
        return OnSuccessModel(
            setPinResponse: nil,
            changePinResponse: nil,
            forgetPinResponse: nil,
            transferResponse: response,
            paymentResponse: nil,
            distributorPaymentResponse: nil,
            cpqrcResponse: nil
        )
    }

    static func forPayment(_ response: PaymentResponse) -> OnSuccessModel {
        return OnSuccessModel(
            setPinResponse: nil,
            changePinResponse: nil,
            forgetPinResponse: nil,
            transferResponse: nil,
            paymentResponse: response,
            distributorPaymentResponse: nil,
            cpqrcResponse: nil
        )
    }

    static func forDistributorPayment(_ response: PaymentResponse) -> OnSuccessModel {
        return OnSuccessModel(
            setPinResponse: nil,
            changePinResponse: nil,
            forgetPinResponse: nil,
            transferResponse: nil,
            paymentResponse: nil,
            distributorPaymentResponse: response,
            cpqrcResponse: nil
        )
    }

    static func forForgotPin(_ response: ForgetPinResponse) -> OnSuccessModel {
        return OnSuccessModel(
            setPinResponse: nil,
            changePinResponse: nil,
            forgetPinResponse: response,
            transferResponse: nil,
            paymentResponse: nil,
            distributorPaymentResponse: nil,
            cpqrcResponse: nil
        )
    }
    
    // Overload for flows that return BaseResponse on reset PIN
    static func forForgotPin(_ response: BaseResponse) -> OnSuccessModel {
        let mapped = ForgetPinResponse(code: response.code, messages: response.messages, details: response.details)
        return OnSuccessModel(
            setPinResponse: nil,
            changePinResponse: nil,
            forgetPinResponse: mapped,
            transferResponse: nil,
            paymentResponse: nil,
            distributorPaymentResponse: nil,
            cpqrcResponse: nil
        )
    }
}

// Kotlin Event wrapper equivalent (non-Codable)
public final class Event<R> {
    private let data: R
    public private(set) var hasEventBeenHandled: Bool = false
    public init(_ data: R) { self.data = data }
    public var content: R? {
        if !hasEventBeenHandled { hasEventBeenHandled = true; return data }
        return nil
    }
    public var oldContent: R { data }
}

// Kotlin AppLocales equivalent
public enum AppLocales: String, Codable {
    case English, Bengali
    public var locale: Locale {
        switch self { case .English: return Locale(identifier: "en"); case .Bengali: return Locale(identifier: "bn") }
    }
}

// Kotlin MessageTypes equivalent (platform-agnostic)
public enum MessageTypes {
    case text(String?)
    case resource(Int)
}
