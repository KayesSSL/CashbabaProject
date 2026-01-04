import Foundation
import Security

public final class Encryptor {
    public static let shared = Encryptor()
    private init() {}

    private var publicKey: SecKey?

    public func initialize(pemData: Data) throws {
        self.publicKey = try Self.loadPublicKey(from: pemData)
    }

    public func encrypt(_ text: String) -> String? {
        guard let key = publicKey else { return nil }
        let data = Data(text.utf8)
        let algorithm: SecKeyAlgorithm = .rsaEncryptionPKCS1
        guard SecKeyIsAlgorithmSupported(key, .encrypt, algorithm) else { return nil }
        var error: Unmanaged<CFError>?
        guard let cipher = SecKeyCreateEncryptedData(key, algorithm, data as CFData, &error) as Data? else {
            return nil
        }
        return cipher.base64EncodedString()
    }
    
    private static func loadPublicKey(from derData: Data) throws -> SecKey {
        let keyDict: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(derData as CFData, keyDict as CFDictionary, &error) else {
            let message = (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "Unknown error"
            throw SDKError.decode("Failed to create SecKey: \(message)")
        }
        return secKey
    }
}
