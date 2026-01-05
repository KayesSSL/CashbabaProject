//
//  SplashVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/27/25.
//
import UIKit

class CBSplashVC: UIViewController {
    weak var coordinator: Coordinating?
    private let args: NavigationArgs
    
    init(args: NavigationArgs) {
        self.args = args
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    lazy var splashView: CBSplashView = {
        let view = CBSplashView()
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("current language is : \(args.languageCode ?? "")")
        let lan = args.languageCode == "en" ? SDKLanguage.English : SDKLanguage.Bangla
        CBSDKLanguageHandler.sharedInstance.switchLanguage(to: lan)
        self.view.addSubview(splashView)
        splashView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
        startFlow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("I am here, Splash")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Splash is terminated")
    }
    
    private func startFlow() {
        print("[SplashVC] startFlow: env=\(args.environment) lang=\(args.languageCode ?? "nil") type=\(args.type)")
        CBProgressHUD.sharedInstance.startAnimation()
        // Ensure global config reflects args
        if let lang = args.languageCode { APIHandler.config.languageCode = lang }
        if let w = args.wToken { APIHandler.config.wToken = w }
        APIHandler.config.environment = args.environment
        // Set required scope per flow (Android parity)
        switch args.type {
        case .SET_PIN, .CHANGE_PIN, .FORGET_PIN:
            APIHandler.config.scope = "PinManagement"
        case .PAYMENT, .DISTRIBUTOR_PAYMENT, .CPQRC:
            APIHandler.config.scope = "Payment"//"Transaction"
        case .TRANSFER_MONEY:
            APIHandler.config.scope = "LinkBank"
        }
        
        CashBaba.shared.clientVerification(clientId: args.clientId, clientSecret: args.clientSecret) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                CBProgressHUD.sharedInstance.stopAnimation()
                switch result {
                case .success:
                    print("[SplashVC] clientVerification success")
                    self.routeAfterVerification()
                case .failure(let err):
                    print("[SplashVC] clientVerification failed: \(err.localizedDescription)")
                    CashBaba.shared.closeSdkOnFailed(err.localizedDescription)
                    self.coordinator?.closeSDK(withError: err.localizedDescription)
                }
            }
        }
    }
    
    private func routeAfterVerification() {
        switch args.type {
        case .SET_PIN:
            coordinator?.navigate(to: .intro, animated: true)
        case .CHANGE_PIN:
            coordinator?.navigate(to: .changePin, animated: true)
        case .FORGET_PIN:
            coordinator?.navigate(to: .forgotPin, animated: true)
        case .TRANSFER_MONEY:
            // Transfer flow goes to Confirm PIN screen
            coordinator?.navigate(to: .confirmPin, animated: true)
        case .PAYMENT:
            coordinator?.navigate(to: .confirmPin, animated: true)
        case .DISTRIBUTOR_PAYMENT:
            coordinator?.navigate(to: .confirmPin, animated: true)
        case .CPQRC:
            // Validate CPQRC first; start face KYC only if required (Android parity)
            coordinator?.startCpqrcFlow(from: self)
        }
    }
}
