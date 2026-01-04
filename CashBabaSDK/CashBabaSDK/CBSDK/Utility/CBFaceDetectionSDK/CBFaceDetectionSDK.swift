//
//  CBFaceDetectionSDK.swift
//  CBFaceDetection
//
//  Created by Mausum Nandy on 25/4/24.
//

import Foundation
import UIKit
public protocol CBFaceDetectionSDKDelegate {
    func images(smile : String, blink: String)
    func userCancelled(_ userBack : String)
    func errorOccured(_ error : String)
  
}
public class CBFaceDetectionSDK {
    private   var nav : UINavigationController?
    private var  inViewController: UIViewController?

    private var delegate : CBFaceDetectionSDKDelegate?
    private var strings : Any?
    public init(inViewController : UIViewController,  delegate : CBFaceDetectionSDKDelegate?,strings : Any?) {
      
        self.delegate = delegate
        self.inViewController = inViewController
        self.strings = strings
    }
    
    public  func launch(){
        
        let vc = FaceDetectionViewController()
        vc.strings = self.strings as? [String : String]
        vc.delegate = self.delegate
//        vc.startDate = Date()
        self.nav  = UINavigationController(rootViewController: vc)
        guard let nc = self.nav else{
            return
        }
        nc.modalPresentationStyle = .fullScreen
        nc.setNavigationBarHidden(true, animated: true)
        self.inViewController?.present(nc, animated: true, completion: nil)
    }
}
