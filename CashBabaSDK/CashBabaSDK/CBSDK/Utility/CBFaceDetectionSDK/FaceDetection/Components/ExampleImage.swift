//
//  ExampleImage.swift
//  CBFaceDetection
//
//  Created by Mausum Nandy on 26/4/24.
//

import UIKit
class ExampleImage: UIView{
    let containter = UIView()
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubview(containter)
        containter.addAnchorToSuperview(leading: 8,trailing: -8,top: 8)
        containter.layer.cornerRadius = 12
        containter.layer.borderColor = UIColor(red: 0.72, green: 0.73, blue: 0.76, alpha: 1).cgColor
        containter.layer.borderWidth = 3
        
        imageView.setImageFromBundle(ExampleImage.self, imageName: "right")
        
        containter.addSubview(imageView)
       // imageView.addAnchorToSuperview(leading: 8,trailing: -8,top: 8,bottom: -8)
        imageView.addAnchorToSuperview(heightMultiplier: 0.8,widthMutiplier: 0.8,centeredVertically: 0,centeredHorizontally: 0)
        
        addSubview(label)
        label.textAlignment = .center
        label.addAnchorToSuperview(leading: 0,trailing: 0,bottom: -8)
        label.topAnchor.constraint(equalTo: containter.bottomAnchor,constant: 5.y).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView : UIImageView = UIImageView()
    
    let label : EasyLabel = EasyLabel(color: UIColor(red: 0.53, green: 0.55, blue: 0.57, alpha: 1), font: .Medium, size: 14.y)
    
    func blinkBorder(){
        containter.blink()
        containter.layer.borderColor =  UIColor(red: 0.13, green: 0.1, blue: 0.58, alpha: 1).cgColor
    }
    
    func stopAnimation(){
        containter.layer.removeAllAnimations()
    }
}
extension UIView {
    func blink(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, alpha: CGFloat = 0.0) {
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.layer.borderColor = self.layer.borderColor?.copy(alpha: 0.1)
        })
    }
}
