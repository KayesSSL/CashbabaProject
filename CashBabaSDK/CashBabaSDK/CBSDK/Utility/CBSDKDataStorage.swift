import Foundation

public final class CBSDKDataStorage {
    public static let shared = CBSDKDataStorage()
    private init() {}

    // Mirrors Android DataStorage
    public var navigationArgs: NavigationArgs?
    public var accessToken: String? {
        get { SessionStore.shared.accessToken }
        set { SessionStore.shared.accessToken = newValue }
    }
    public var languageCode: String {
        get { APIHandler.config.languageCode }
        set { APIHandler.config.languageCode = newValue }
    }
    public var forgetPinIdentifier: String = ""
    public var environment: Environment {
        get { APIHandler.config.environment }
        set { APIHandler.config.environment = newValue }
    }
    public var baseURL: String {
        get { APIHandler.config.environment.baseURL }
    }
    public var tokenExpireInMillis: Int64 {
        get {
            guard let exp = SessionStore.shared.tokenExpiry else { return 0 }
            return Int64(max(0, exp.timeIntervalSinceNow * 1000))
        }
        set {
            // Allow setting via seconds if needed; prefer SessionStore.updateToken
            SessionStore.shared.tokenExpiry = Date().addingTimeInterval(TimeInterval(newValue) / 1000.0)
        }
    }
    // CPQRC scratch values
    public var cpqrcValidationData: CpqrcValidationData?
    public var smileFacePath: String?
    public var blinkFacePath: String?
}
