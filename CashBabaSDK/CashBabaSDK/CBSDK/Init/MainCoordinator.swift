import UIKit

final class MainCoordinator: Coordinating {
    let navigationController: UINavigationController
    let args: NavigationArgs
    private var splashOverlay: CBSplashVC?
    // Retain face detection SDK during capture to receive delegate callbacks
    private var faceSDK: CBFaceDetectionSDK?

    init(navigationController: UINavigationController, args: NavigationArgs) {
        self.navigationController = navigationController
        self.args = args
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.isHidden = true
    }

    func start() {
        navigate(to: .splash, animated: false)
    }

    func navigate(to route: Route, animated: Bool) {
        print("[Coordinator] navigate -> \(route)")

        // Handle Splash as an overlay child VC to avoid black flicker during transitions
        if case .splash = route {
            if splashOverlay == nil {
                let vc = CBSplashVC(args: args)
                vc.coordinator = self
                splashOverlay = vc
                print("[Coordinator] add Splash overlay as child")
                addSplashOverlay(vc)
            }
            return
        } else if let splash = splashOverlay {
            print("[Coordinator] fade out Splash overlay before navigating to \(route) splash: \(splash.debugDescription)")
            removeSplashOverlayAnimated { [weak self] in
                self?.splashOverlay = nil
                self?.performPush(for: route, animated: animated)
            }
            return
        }

        performPush(for: route, animated: animated)
    }

    private func performPush(for route: Route, animated: Bool) {
        switch route {
        case .splash:
            // handled above
            break

        case .intro:
            let vc = WelcomeVC()
            vc.coordinator = self
            print("[Coordinator] push WelcomeVC")
            navigationController.pushViewController(vc, animated: animated)

        case .changePin:
            let vc = ChangePINVC()
            vc.coordinator = self
            print("[Coordinator] push ChangePINVC")
            navigationController.pushViewController(vc, animated: animated)

        case .forgotPin:
            let vc = ForgetPinVC()
            vc.coordinator = self
            print("[Coordinator] push ForgetPinVC")
            navigationController.pushViewController(vc, animated: animated)

        case .pinSetup(let type):
            let vc = PINSetupVC(verifyOTPType: type)
            vc.coordinator = self
            print("[Coordinator] push PINSetupVC type=\(type)")
            // Option A: adjust stack so Back from PINSetup goes to Welcome (skip OTP) for setPin flow
            if case .setPin = type {
                var stack = navigationController.viewControllers
                if let last = stack.last, last is OTPVerificationVC {
                    // Remove OTPVerificationVC and append PINSetupVC
                    _ = stack.popLast()
                    stack.append(vc)
                    navigationController.setViewControllers(stack, animated: animated)
                } else {
                    navigationController.pushViewController(vc, animated: animated)
                }
            } else {
                navigationController.pushViewController(vc, animated: animated)
            }

        case .verifyOTP(let type):
            let vc = OTPVerificationVC(verifyOTPType: type)
            vc.coordinator = self
            print("[Coordinator] push OTPVerificationVC type=\(type)")
            navigationController.pushViewController(vc, animated: animated)
        case .confirmPin:
            let vc = ConfirmPINVC()
            vc.coordinator = self
            print("[Coordinator] push ConfirmPINVC")
            navigationController.pushViewController(vc, animated: animated)
        }
    }

    // MARK: - Splash Overlay Helpers
    private func addSplashOverlay(_ vc: CBSplashVC) {
        guard let containerView = navigationController.view else { return }
        navigationController.addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        vc.didMove(toParent: navigationController)
        vc.view.alpha = 0
        UIView.animate(withDuration: 0.2) {
            vc.view.alpha = 1
        }
    }

    private func removeSplashOverlayAnimated(completion: @escaping () -> Void) {
        guard let splash = splashOverlay else { completion(); return }
        UIView.animate(withDuration: 0.5, animations: {
            splash.view.alpha = 0
        }) { _ in
            splash.willMove(toParent: nil)
            splash.view.removeFromSuperview()
            splash.removeFromParent()
            completion()
        }
    }

    func closeSDK(withError message: String?) {
        CashBaba.shared.closeSdkOnFailed(message ?? "session_expired".sslComLocalized())
        navigationController.presentingViewController?.dismiss(animated: true)
    }
    
    func closeSDKSuccess() {
        navigationController.presentingViewController?.dismiss(animated: true)
        CashBaba.shared.onUserCancel?()
    }

    func closeSDKSuccessWithResult(_ result: OnSuccessModel) {
        navigationController.presentingViewController?.dismiss(animated: true) { [weak self] in
            _ = self // keep capture semantics explicit
            CashBaba.shared.onSuccess?(result)
        }
    }

    // MARK: - CPQRC Face KYC Integration
    func startFaceKYC(from presenter: UIViewController) {
        // Optional localized strings map used by FaceDetection SDK
        let instruction = "blink_eyes".sslComLocalized()
        let back = "back".sslComLocalized()
        let strings: [String: String] = [
            "instruction": instruction,
            "back": back
        ]

        let sdk = CBFaceDetectionSDK(inViewController: presenter, delegate: self, strings: strings)
        self.faceSDK = sdk
        sdk.launch()
    }

    // MARK: - CPQRC Flow Entry (Validate then optional Face KYC)
    func startCpqrcFlow(from presenter: UIViewController) {
        guard let paymentRef = args.paymentReference, !paymentRef.isEmpty else {
            CashBaba.shared.closeSdkOnFailed("Missing payment reference")
            closeSDK(withError: "Missing payment reference")
            return
        }
        CBProgressHUD.sharedInstance.startAnimation()
        CashBaba.shared.cpqrcValidate(paymentReference: paymentRef) { [weak self] result in
            guard let self = self else { return }
            CBProgressHUD.sharedInstance.stopAnimation()
            switch result {
            case .success:
                let requireFace = CBSDKDataStorage.shared.cpqrcValidationData?.isFaceVerificationRequired == true
                if requireFace {
                    self.startFaceKYC(from: presenter)
                } else {
                    self.navigate(to: .verifyOTP(verifyOTPType: .cpqrcPayment), animated: true)
                }
            case .failure(let err):
                CashBaba.shared.closeSdkOnFailed(err.localizedDescription)
                self.closeSDK(withError: err.localizedDescription)
            }
        }
    }
}

// MARK: - CBFaceDetectionSDKDelegate
extension MainCoordinator: CBFaceDetectionSDKDelegate {
    func images(smile: String, blink: String) {
        CBSDKDataStorage.shared.smileFacePath = smile
        CBSDKDataStorage.shared.blinkFacePath = blink
        self.faceSDK = nil
        // Validation already performed in startCpqrcFlow; proceed to OTP
        navigate(to: .verifyOTP(verifyOTPType: .cpqrcPayment), animated: true)
    }

    func userCancelled(_ userBack: String) {
        self.faceSDK = nil
        closeSDKSuccess()
    }

    func errorOccured(_ error: String) {
        self.faceSDK = nil
        CashBaba.shared.closeSdkOnFailed(error)
        closeSDK(withError: error)
    }
}
