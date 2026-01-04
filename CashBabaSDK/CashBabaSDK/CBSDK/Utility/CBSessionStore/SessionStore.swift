import Foundation

public final class SessionStore {
    public static let shared = SessionStore()
    private init() {}

    public var accessToken: String? {
        didSet { APIHandler.config.accessToken = accessToken }
    }
    public var tokenExpiry: Date?

    public func updateToken(accessToken: String?, expiresInSeconds: Int?) {
        self.accessToken = accessToken
        if let s = expiresInSeconds {
            self.tokenExpiry = Date().addingTimeInterval(TimeInterval(s))
        }
    }

    public var isTokenExpired: Bool {
        guard let exp = tokenExpiry else { return true }
        return Date() >= exp
    }
}
