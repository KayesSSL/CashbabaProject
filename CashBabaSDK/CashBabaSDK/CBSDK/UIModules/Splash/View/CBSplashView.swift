//
//  SplashView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/27/25.
//

import UIKit

class CBSplashView: UIView {
    
    
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .white
        
    }
    
}
