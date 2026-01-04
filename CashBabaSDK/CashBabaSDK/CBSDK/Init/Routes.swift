import UIKit

public enum VerifyOTPType {
    case setPin
    case changePin
    case forgotPin
    case cpqrcPayment
}

public enum Route {
    case splash
    case intro
    case changePin
    case forgotPin
    case confirmPin
    case pinSetup(verifyOTPType: VerifyOTPType)
    case verifyOTP(verifyOTPType: VerifyOTPType)
}

public protocol Coordinating: AnyObject {
    func navigate(to route: Route, animated: Bool)
    func closeSDK(withError message: String?)
    func closeSDKSuccess()
    func closeSDKSuccessWithResult(_ result: OnSuccessModel)
    // CPQRC Face KYC entry point
    func startFaceKYC(from presenter: UIViewController)
    // CPQRC full flow entry: validate first, then optionally face KYC
    func startCpqrcFlow(from presenter: UIViewController)
}

// Provides access to coordinator from base class without importing specific VCs
public protocol CoordinatorAccessible: AnyObject {
    var coordinator: Coordinating? { get }
}
