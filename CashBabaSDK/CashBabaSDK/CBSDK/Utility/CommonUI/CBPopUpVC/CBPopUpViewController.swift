//
//  CBPopUpViewController.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/13/25.
//

import UIKit

enum CBPopUpOptions {
    case bannerImage(image:EasyPopUpImage)
    case image(image:EasyPopUpImage)
    case title(str:String,color:UIColor)
    case subtitle(str:String,color:UIColor)
    case consent(str:String,color:UIColor)
    case buttons(buttons:[PopupButton])
}
protocol CBPopUpDelegate {
    func popupDismissedWith(button:PopupButton,consent:Bool?,rating:Int?)
}

class CBPopUpViewController: UIViewController {
    lazy var mView: CBPopUpView = {
        let mView = CBPopUpView(options: options)
        mView.buttonCallBack = buttonCallback(_:)
        return mView
    }()
    var delegate:CBPopUpDelegate?
    var options: [CBPopUpOptions] = []
    override func viewDidLoad() {
        self.view = mView
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
       
    }
    func buttonCallback(_ sender: PopupButton){
        self.dismiss(animated: true) {
            self.delegate?.popupDismissedWith(button: sender,consent: self.mView.consented, rating: 1)
        }
    }
}

enum EasyPopUpImage{
    case success,failed,other(image: UIImage)

    var image : UIImage?{
        switch self {
        case .success:
            let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "success", withExtension: "gif")!)
            return UIImage.gifImageWithData(imageData!)
        case .failed:
            let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "failed", withExtension: "gif")!)
            return UIImage.gifImageWithData(imageData!)
        case .other(let image):
            return image
        }
    }
}
