import Foundation

public enum Environment {
    case demo
    case live

    public var baseURL: String {
        switch self {
        case .demo:
            return "https://psp.sslwireless.com/psp-app-consumer-sdk/api/"
        case .live:
            return "https://consumer-sdk-api.cash-baba.com/api/"
        }
    }
}

public struct CashBabaConfig {
    public var environment: Environment
    public var languageCode: String // "en" or "bn"
    public var scope: String?       // "PinManagement" | "Transaction" | "LinkBank"
    public var wToken: String?
    public var accessToken: String?

    public init(environment: Environment, languageCode: String = "en", scope: String? = nil, wToken: String? = nil, accessToken: String? = nil) {
        self.environment = environment
        self.languageCode = languageCode
        self.scope = scope
        self.wToken = wToken
        self.accessToken = accessToken
    }
}
