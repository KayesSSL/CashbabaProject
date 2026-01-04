import UIKit

//public enum MethodTypes: String {
//    case SET_PIN
//    case CHANGE_PIN
//    case FORGET_PIN
//    case TRANSFER_MONEY
//    case PAYMENT
//    case DISTRIBUTOR_PAYMENT
//    case CPQRC
//}

public struct NavigationArgs {
    public let type: MethodTypes
    public let wToken: String?
    public let languageCode: String?
    public let environment: Environment
    public let paymentReference: String?
    public let clientId: String
    public let clientSecret: String
    public let phone: String?
    public let transferInfo: TransferInfo?

    public init(type: MethodTypes,
                wToken: String? = nil,
                languageCode: String? = nil,
                environment: Environment,
                paymentReference: String? = nil,
                clientId: String,
                clientSecret: String,
                phone: String? = nil,
                transferInfo: TransferInfo? = nil) {
        self.type = type
        self.wToken = wToken
        self.languageCode = languageCode
        self.environment = environment
        self.paymentReference = paymentReference
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.phone = phone
        self.transferInfo = transferInfo
    }
}

public enum SDKStartRouteDecider {
    public static func route(for args: NavigationArgs) -> Route {
        switch args.type {
        case .SET_PIN:
            return .splash
        case .CHANGE_PIN:
            return .changePin
        case .FORGET_PIN:
            return .forgotPin
        case .TRANSFER_MONEY:
            // Typically goes through confirm pin; start with splash or intro if desired
            return .verifyOTP(verifyOTPType: .setPin) // placeholder, adjust to your flow
        case .PAYMENT, .DISTRIBUTOR_PAYMENT, .CPQRC:
            // These flows usually validate then OTP; start at splash or an entry screen
            return .splash
        }
    }
}

public enum SDKPresenter {
    // Strongly retain the coordinator to keep navigation working
    private static var retainedCoordinator: MainCoordinator?
    private static var isActiveSession: Bool = false
    public static func present(from host: UIViewController,
                               args: NavigationArgs,
                               onSuccess: ((OnSuccessModel) -> Void)? = nil,
                               onFailed: ((OnFailedModel) -> Void)? = nil,
                               onUserCancel: (() -> Void)? = nil) {
        // Configure SDK global settings from args
        if let lang = args.languageCode { APIHandler.config.languageCode = lang }
        if let w = args.wToken { APIHandler.config.wToken = w }
        APIHandler.config.environment = args.environment

        // Reset any previous SDK session state (timers/observers) to avoid immediate timeout callbacks
        CashBaba.shared.resetSession()

        // Build nav + coordinator
        let nav = UINavigationController()
        let coord = MainCoordinator(navigationController: nav, args: args)
        SDKPresenter.retainedCoordinator = coord

        // Set callbacks: always dismiss SDK UI before forwarding to host
        CashBaba.shared.setCallbacks(
            onSuccess: { result in
                // Stop timer when SDK completes successfully
                CashBaba.shared.resetSession()
                onSuccess?(result)
            },
            onFailed: { failure in
                weak var weakNav = nav
                DispatchQueue.main.async {
                    guard isActiveSession else { return }
                    isActiveSession = false
                    // Stop timer when SDK fails
                    CashBaba.shared.resetSession()
                    weakNav?.presentingViewController?.dismiss(animated: true) {
                        SDKPresenter.retainedCoordinator = nil
                        onFailed?(failure)
                    }
                }
            },
            onUserCancel: {
                weak var weakNav = nav
                DispatchQueue.main.async {
                    guard isActiveSession else { return }
                    isActiveSession = false
                    // Stop timer when user cancels
                    CashBaba.shared.resetSession()
                    weakNav?.presentingViewController?.dismiss(animated: true) {
                        SDKPresenter.retainedCoordinator = nil
                        onUserCancel?()
                    }
                }
            }
        )
        // Mirror Android DataStorage.model
        CBSDKDataStorage.shared.navigationArgs = args

        // Present nav first, then start coordinator so Splash can be presented safely
        host.present(nav, animated: true) {
            isActiveSession = true
            coord.start()
        }
    }
}
