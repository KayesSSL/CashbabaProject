//
//  CBProgressHUD.swift
//  CBSDKTestApp
//
//  Created by [Your Name] on [Date]
//

import UIKit

final public class CBProgressHUD: UIView {
    public static let sharedInstance = CBProgressHUD()
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let arcLayer = CAShapeLayer()
    
    // MARK: - Layout Constants
    private let containerSize: CGFloat = 100
    private let containerCornerRadius: CGFloat = 18
    private let containerShadowOpacity: Float = 0.18
    private let arcLineWidth: CGFloat = 6
    private let arcRadius: CGFloat = 22
    private let arcColor = UIColor(red: 235/255, green: 118/255, blue: 47/255, alpha: 1.0) // #EB762F
    private let overlayColor = UIColor(white: 0.35, alpha: 1.0)
    
    private var isAnimating = false
    
    private override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupHUD()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHUD() {
        backgroundColor = overlayColor
        
        // Centered white container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = containerCornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = containerShadowOpacity
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: containerSize),
            containerView.heightAnchor.constraint(equalToConstant: containerSize)
        ])
        
        // Arc Spinner - fixed arc for smooth animation
        let arcCenter = CGPoint(x: containerSize / 2, y: containerSize / 2)
        let arcPath = UIBezierPath(
            arcCenter: arcCenter,
            radius: arcRadius,
            startAngle: -.pi / 2, // Start at 12 o'clock
            endAngle: 1.5 * .pi,  // End at 9 o'clock for a 270-degree arc
            clockwise: true
        )
        
        arcLayer.path = arcPath.cgPath
        arcLayer.lineWidth = arcLineWidth
        arcLayer.strokeColor = arcColor.cgColor
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.lineCap = .round
        arcLayer.frame = CGRect(origin: .zero, size: CGSize(width: containerSize, height: containerSize))
        
        // Show 75% of the circle (fixed)
        arcLayer.strokeStart = 0.0
        arcLayer.strokeEnd = 0.75
        
        containerView.layer.addSublayer(arcLayer)
    }
    
    // MARK: - Animation
    public func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                self.frame = window.bounds
                window.addSubview(self)
                window.bringSubviewToFront(self)
            }
            self.animateSpinner()
        }
    }
    
    public func stopAnimation() {
        guard isAnimating else { return }
        isAnimating = false
        
        DispatchQueue.main.async {
            self.arcLayer.removeAllAnimations()
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Smooth, Continuous Spinner Animation
    private func animateSpinner() {
        arcLayer.removeAllAnimations()
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        arcLayer.add(rotation, forKey: "rotation")
    }
}
