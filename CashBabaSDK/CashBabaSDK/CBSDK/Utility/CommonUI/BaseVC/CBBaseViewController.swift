//
//  BaseViewController.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import UIKit

public class CBBaseViewController: UIViewController {
    
    private(set) var currentLanguage = CBSDKLanguageHandler.sharedInstance.getCurrentLanguage()

    private let appBarView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private lazy var timerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.addSubview(timeLabel)
        timeLabel.addAnchorToSuperview(leading: 4, trailing: -4, top: 4, bottom: -4)
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:23"
        label.textAlignment = .center
        label.font = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 11)
        return label
    }()

    public var customTitle: String = "" {
        didSet {
            titleLabel.text = customTitle
        }
    }

    public var isBackButtonHidden: Bool = false {
        didSet {
            backButton.isHidden = isBackButtonHidden
        }
    }

    private let appBarColor = UIColor(red: 235/255, green: 118/255, blue: 47/255, alpha: 1.0)
    private let appBarContentHeight: CGFloat = 56.0

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .white
        setupAppBar()
        backButton.isHidden = isBackButtonHidden
        self.navigationItem.hidesBackButton = true
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        let hideKeybaordGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_ :)))
        hideKeybaordGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(hideKeybaordGesture)
        
        //language delegate setup
        CBSDKLanguageHandler.sharedInstance.addDelegate(self)

        // Observe timer ticks (timer is managed by CashBabaSDK after clientVerification)
        NotificationCenter.default.addObserver(self, selector: #selector(timerTicked), name: .sessionTimerDidTick, object: nil)
        updateTimeLabel() // Set initial time label
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .sessionTimerDidTick, object: nil)
    }

    // Do not stop the shared timer on per-screen transitions; it is managed centrally by the SDK
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // Do not reset the timer when navigating between VC1, VC2, VC3
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTimeLabel() // Update the time label with the latest timer value
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @objc func hideKeyboard(_ sender:UITapGestureRecognizer){
        self.view.endEditing(true)
    }

    private var statusBarHeight: CGFloat {
        if let window = view.window ?? UIApplication.shared.windows.first {
            if #available(iOS 13.0, *) {
                return window.windowScene?.statusBarManager?.statusBarFrame.height ?? window.safeAreaInsets.top
            } else {
                return UIApplication.shared.statusBarFrame.height
            }
        }
        return 0
    }
    
    internal func formattedTimeStringFrom(timeInterval: TimeInterval) -> String {
        if timeInterval.isNaN {
            return "00:00:00"
        }
        let hours = Int(timeInterval / 3600)
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return timeInterval > 3600 ?  String(format:"%02i:%02i:%02i" ,hours, minutes, seconds) : String(format:"%02i:%02i" , minutes, seconds)
    }
    
    var appBarTotalHeight: CGFloat { statusBarHeight + appBarContentHeight }

    private func setupAppBar() {
        appBarView.backgroundColor = appBarColor
        appBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appBarView)

        NSLayoutConstraint.activate([
            appBarView.topAnchor.constraint(equalTo: view.topAnchor),
            appBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            appBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            appBarView.heightAnchor.constraint(equalToConstant: statusBarHeight + appBarContentHeight)
        ])

        backButton.setImage(UIImage.imageFromBundle(CBBaseViewController.self, imageName: "back")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        appBarView.addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: FontManager.shared.fonts.interSemiBold, size: 18)
        titleLabel.text = customTitle
        titleLabel.backgroundColor = .clear
        titleLabel.isUserInteractionEnabled = false
        appBarView.addSubview(titleLabel)
        
        appBarView.addSubview(timerView)
        timerView.addAnchorToSuperview(trailing: -16)
        timerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        timerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: appBarView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: appBarView.topAnchor, constant: statusBarHeight + appBarContentHeight / 2),
            backButton.widthAnchor.constraint(equalToConstant: 10),
            backButton.heightAnchor.constraint(equalToConstant: 21),

            titleLabel.centerXAnchor.constraint(equalTo: appBarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timerView.trailingAnchor, constant: -8),
            timerView.centerYAnchor.constraint(equalTo: appBarView.topAnchor, constant: statusBarHeight + appBarContentHeight / 2)
        ])
        
        timerView.layer.cornerRadius = 10
    }

    @objc open func backButtonTapped() {
        print("Custom back button tapped")
        if let nav = navigationController {
            if nav.viewControllers.first != self {
                nav.popViewController(animated: true)
                return
            }
            if let _ = (self as? CoordinatorAccessible)?.coordinator {
                self.coordinatorCloseSDKSuccess()
                return
            }
            dismiss(animated: true) {
                CashBaba.shared.onUserCancel?()
            }
        } else if presentingViewController != nil {
            dismiss(animated: true) {
                CashBaba.shared.onUserCancel?()
            }
        }
    }
    
    @objc private func timerTicked() {
        updateTimeLabel()
    }
    
    private func updateTimeLabel() {
        let seconds = SessionTimerManager.shared.remainingSeconds
        timeLabel.text = formattedTimeStringFrom(timeInterval: TimeInterval(seconds))
    }

    // Helper available to all SDK VCs (including BaseViewController) to close via coordinator
    func coordinatorCloseSDKSuccess() {
        if let coord = (self as? CoordinatorAccessible)?.coordinator {
            coord.closeSDKSuccess()
        } else if presentingViewController != nil {
            dismiss(animated: true) {
                CashBaba.shared.onUserCancel?()
            }
        }
    }
}

extension CBBaseViewController: CBSDKLanguageDelegate {
    public func languageDidChange(to language: SDKLanguage) {
        currentLanguage = language
    }
}

// MARK: - Coordinator helpers
extension CoordinatorAccessible where Self: UIViewController {
    func coordinatorCloseSDKSuccess() {
        if let coord = self.coordinator {
            coord.closeSDKSuccess()
        } else if self.presentingViewController != nil {
            self.dismiss(animated: true) {
                CashBaba.shared.onUserCancel?()
            }
        }
    }
}

