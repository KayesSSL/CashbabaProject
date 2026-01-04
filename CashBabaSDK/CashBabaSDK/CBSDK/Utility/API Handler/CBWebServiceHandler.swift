//
//  WebServiceHandler.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation

public final class CBWebServiceHandler {
    public static let shared = CBWebServiceHandler()
    private init() {}

    // Centralized decode with server code handling
    // Supports both wrapped { code, messages, details, data } and plain models
    private func decodeTo<T: Decodable>(_ data: Data?) -> Result<T, Error> {
        guard let data = data else {
            return .failure(SDKError.decode("Empty response"))
        }

        // Try to inspect a top-level wrapper for code/messages
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let code = json["code"] as? Int {
            // Handle success and error codes explicitly
            if code == 200 || code == 201 {
                // proceed to decode below
            } else {
                let message = (json["messages"] as? [String])?.joined(separator: ", ")
                              ?? (json["details"] as? String)
                              ?? "Unknown server error"
                // Do not close SDK here; centralized in APIHandler
                return .failure(SDKError.server(message))
            }

            // Success with wrapper:
            // 1) Prefer decoding the full body into T (works for wrapper models like PinValidationResponse)
            if let fullDecoded = try? JSONDecoder().decode(T.self, from: data) {
                return .success(fullDecoded)
            }
            // 2) If that fails, try decoding T from the `data` field (works when T is the inner payload type)
            if let payload = json["data"], !(payload is NSNull),
               let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) {
                if let decoded = try? JSONDecoder().decode(T.self, from: payloadData) {
                    return .success(decoded)
                }
            }
        }

        do { return .success(try JSONDecoder().decode(T.self, from: data)) }
        catch { return .failure(error) }
    }

    // MARK: - Auth
    func clientVerification(clientId: String, clientSecret: String, completion: @escaping (Result<ClientVerificationResponse, Error>) -> Void) {
        let fields = [
            "grant_type": "client_credentials",
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        APIHandler.makePostForm(path: ApiPaths.clientVerify, fields: fields, requireAuth: false, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    // MARK: - PIN
    func setPin(pin: String, confirmPin: String, completion: @escaping (Result<SetPinResponse, Error>) -> Void) {
        let encPin = Encryptor.shared.encrypt(pin) ?? ""
        let encConfirm = Encryptor.shared.encrypt(confirmPin) ?? ""
        let fields = ["Pin": encPin, "ConfirmPin": encConfirm]
        APIHandler.makePostForm(path: ApiPaths.setPin, fields: fields, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    // CORRECTED: Now returns GetSetOtpResponse
    func getSetPinOtp(completion: @escaping (Result<GetSetOtpResponse, Error>) -> Void) {
        APIHandler.makePostForm(path: ApiPaths.getSetPinOtp, fields: [:], requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func verifySetPinOtp(otp: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.makePostForm(path: ApiPaths.verifySetPinOtp, fields: ["OTP": otp], requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func getPinRules(completion: @escaping (Result<PinValidationResponse, Error>) -> Void) {
        APIHandler.makeGetRequest(path: ApiPaths.pinRules, query: nil, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func changePin(oldPin: String, pin: String, confirmPin: String, completion: @escaping (Result<ChangePinResponse, Error>) -> Void) {
        let fields = [
            "OldPin": Encryptor.shared.encrypt(oldPin) ?? "",
            "Pin": Encryptor.shared.encrypt(pin) ?? "",
            "ConfirmPin": Encryptor.shared.encrypt(confirmPin) ?? ""
        ]
        APIHandler.makePostForm(path: ApiPaths.changePin, fields: fields, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func forgotPin(nationalId: String, dateOfBirth: String, completion: @escaping (Result<ForgetPinResponse, Error>) -> Void) {
        let fields = ["NationalId": nationalId, "DateOfBirth": dateOfBirth]
        APIHandler.makePostForm(path: ApiPaths.forgotPin, fields: fields, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func forgotPinOtpVerify(otp: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.makePostForm(path: ApiPaths.forgotPinOtpVerify, fields: ["OTP": otp], requireAuth: true, onSuccess: { data in
            if let d = data, let res = try? JSONDecoder().decode(ForgotPinVerifyResponse.self, from: d) {
                CBSDKDataStorage.shared.forgetPinIdentifier = res.data?.identifier ?? ""
            }
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func forgotPinOtpResend(completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        APIHandler.makePostForm(path: ApiPaths.forgotPinOtpResend, fields: [:], requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func resetPin(identifier: String, pin: String, confirmPin: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        let fields = [
            "Identifier": identifier,
            "Pin": Encryptor.shared.encrypt(pin) ?? "",
            "ConfirmPin": Encryptor.shared.encrypt(confirmPin) ?? ""
        ]
        APIHandler.makePostForm(path: ApiPaths.resetPin, fields: fields, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    // MARK: - Transactions
    func confirmPinForTransfer(bankTokenNo: String, transactionAmount: String, pin: String, purpose: String, completion: @escaping (Result<TransferResponse, Error>) -> Void) {
        let fields: [String: Any] = [
            "BankTokenNo": bankTokenNo,
            "TransactionAmount": transactionAmount,
            "Pin": Encryptor.shared.encrypt(pin) ?? "",
            "Purpose": purpose
        ]
        APIHandler.makePostForm(path: ApiPaths.transfer, fields: fields, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func confirmPayment(paymentReference: String, pin: String, completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        let fields = ["PaymentReference": paymentReference, "Pin": Encryptor.shared.encrypt(pin) ?? ""]
        APIHandler.makePostForm(path: ApiPaths.payment, fields: fields, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func confirmDistributorPayment(paymentReference: String, pin: String, completion: @escaping (Result<PaymentResponse, Error>) -> Void) {
        let fields = ["PaymentReference": paymentReference, "Pin": Encryptor.shared.encrypt(pin) ?? ""]
        APIHandler.makePostForm(path: ApiPaths.distributorPayment, fields: fields, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    // MARK: - CPQRC
    func validateCpQrcPayment(paymentReference: String, completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void) {
        APIHandler.makeGetRequest(path: ApiPaths.validateCpqrc(paymentReference), query: nil, requireAuth: true, onSuccess: { data in
            if let d = data, let res = try? JSONDecoder().decode(CpqrcValidationResponse.self, from: d) {
                CBSDKDataStorage.shared.cpqrcValidationData = res.data
            }
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func confirmCpqrcPayment(transactionId: String, otp: String, smileImage: Data?, blinkImage: Data?, completion: @escaping (Result<CpqrcPaymentConfirmResponse, Error>) -> Void) {
        var parts: [MultipartPart] = [
            MultipartPart(name: "TransactionId", data: Data(transactionId.utf8)),
            MultipartPart(name: "Otp", data: Data(otp.utf8))
        ]
        if let s = smileImage {
            let mime = detectImageMime(data: s) ?? "image/jpeg"
            let filename = mime == "image/png" ? "SmileImage.png" : "SmileImage.jpg"
            parts.append(MultipartPart(name: "SmileImage", data: s, filename: filename, mimeType: mime))
        }
        if let b = blinkImage {
            let mime = detectImageMime(data: b) ?? "image/jpeg"
            let filename = mime == "image/png" ? "BlinkImage.png" : "BlinkImage.jpg"
            parts.append(MultipartPart(name: "BlinkImage", data: b, filename: filename, mimeType: mime))
        }
        APIHandler.makePostMultipart(path: ApiPaths.confirmCpqrc, parts: parts, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    // Simple MIME detector for JPEG/PNG
    private func detectImageMime(data: Data) -> String? {
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) { return "image/png" } // PNG signature
        if data.starts(with: [0xFF, 0xD8, 0xFF]) { return "image/jpeg" } // JPEG signature
        return nil
    }

    func verifyCpqrcPayment(paymentReference: String, completion: @escaping (Result<CpqrcValidationResponse, Error>) -> Void) {
        APIHandler.makeGetRequest(path: ApiPaths.verifyCpqrc(paymentReference), query: nil, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }

    func resendCpqrcPaymentOtp(transactionId: String, completion: @escaping (Result<BaseResponse, Error>) -> Void) {
        let path = ApiPaths.resendCpqrcOtp + "/\(transactionId)"
        APIHandler.makeGetRequest(path: path, query: nil, requireAuth: true, onSuccess: { data in
            completion(self.decodeTo(data))
        }, onFailure: { err in
            let message = err ?? "Unknown error"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.server(message)))
        }, onConnectionFailure: {
            let message = "No connection"
            CashBaba.shared.closeSdkOnFailed(message)
            completion(.failure(SDKError.network(message)))
        })
    }
}
