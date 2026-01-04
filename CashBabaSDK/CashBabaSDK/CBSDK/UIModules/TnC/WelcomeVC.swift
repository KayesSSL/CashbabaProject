//
//  WelcomeVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/27/25.
//
import UIKit

class WelcomeVC: CBBaseViewController, CoordinatorAccessible {
    weak var coordinator: Coordinating?
    
    lazy var welcomeView: WelcomeView = {
        let view = WelcomeView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(welcomeView)
        welcomeView.addAnchorToSuperview(leading: 0, trailing: 0, top: appBarTotalHeight, bottom: 0)

        // Handle Proceed tap -> navigate to VerifyOTP with SET_PIN (Android IntroScreen parity)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onProceedTapped))
        welcomeView.proceedButtonContainer.isUserInteractionEnabled = true
        welcomeView.proceedButtonContainer.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc private func onProceedTapped() {
        coordinator?.navigate(to: .verifyOTP(verifyOTPType: .setPin), animated: true)
    }
}
