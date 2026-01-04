//
//  CBErrorVC.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/29/25.
//
import Foundation
import UIKit

protocol CBErrorDelegate {
    func vcDismissedWith(button:UIButton)
}

class CBErrorVC: UIViewController {
    lazy var mView: CBErrorView = {
        let mView = CBErrorView()
        mView.buttonCallBack = buttonCallback(_:)
        return mView
    }()
    
    var delegate:CBErrorDelegate?
    
    override func viewDidLoad() {
        self.view = mView
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
       
    }
    
    func buttonCallback(_ sender: UIButton){
        self.dismiss(animated: true) {
            self.delegate?.vcDismissedWith(button: sender)
        }
    }
}
