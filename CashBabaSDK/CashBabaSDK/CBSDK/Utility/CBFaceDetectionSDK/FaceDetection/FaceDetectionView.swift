//
//  FaceDetectionView.swift
//  CBFaceDetection
//
//  Created by Mausum Nandy on 25/4/24.
//

import UIKit

class FaceDetectionView: UIView {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor  = UIColor(red: 0.188, green: 0.541, blue: 0.396, alpha: 1)
        addSubview(navigationView)
      
        navigationView.addAnchorToSuperview(leading: 0,trailing: 0, heightMultiplier: 0.08)
        navigationView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,constant: 0).isActive = true
        
        addSubview(indicatorView)
        indicatorView.addAnchorToSuperview(widthMutiplier: 0.6,centeredHorizontally: 0,heightWidthRatio: 1.5)
          indicatorView.topAnchor.constraint(equalTo: navigationView.bottomAnchor,constant: 0).isActive = true
        
        falseView.backgroundColor = UIColor(red: 0.188, green: 0.541, blue: 0.396, alpha: 1)
       
        addSubview(falseView)
        falseView.addAnchorToSuperview(widthMutiplier: 0.58,heightWidthRatio: 1.5)
        falseView.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor).isActive = true
        falseView.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor).isActive = true
       
        
        addSubview(preview)
        preview.addAnchorToSuperview(widthMutiplier: 0.55,heightWidthRatio: 1.5)
        preview.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor).isActive = true
        preview.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor).isActive = true
        
        addSubview(progressView)
        progressView.addAnchorToSuperview(leading: 0,trailing: 0,bottom: 0,heightMultiplier: 0.4)

        
        
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let falseView = UIView()
    let navTitle = EasyLabel(color: .white, font: .Bold, size: 16)
    
    lazy var navigationView : UIView = {
        let view = UIView()
        view.addSubview(backButton)
        backButton.addAnchorToSuperview(leading: 16,top: 0,widthMutiplier: 0.1,heightWidthRatio: 1)
        

        view.addSubview(navTitle)
        navTitle.addAnchorToSuperview(centeredVertically: 0,centeredHorizontally: 0)
   
        
        return view
    }()
    let backButton : UIButton = {
        let backButton = UIButton()
        backButton.setImageFromBundle(FaceDetectionView.self, imageName: "ic_back", for: .normal)
        return backButton
    }()
    
    let helpButton : UIButton = {
        let backButton = UIButton()
        backButton.setImageFromBundle(FaceDetectionView.self, imageName: "ic_help", for: .normal)
        return backButton
    }()
    let recordLabel: EasyLabel = {
        let recordLabel = EasyLabel(color: .black, font: .Bold, size: 24)
        recordLabel.text = "Smile"
        recordLabel.textAlignment = .center
        return recordLabel
    }()
    let messageLabel = EasyLabel(color: UIColor(red: 0.39, green: 0.4, blue: 0.42, alpha: 1), font: .Medium, size: 14)
    lazy var progressView: UIView = {
        let view = UIView()
        view.backgroundColor  =  UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        
       
        view.addSubview(recordLabel)
        recordLabel.addAnchorToSuperview(leading : 16, trailing : -16,top:  25)
        
        
       
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        view.addSubview(messageLabel)
        messageLabel.addAnchorToSuperview(leading : 16, trailing : -16)
        messageLabel.topAnchor.constraint(equalTo: recordLabel.bottomAnchor,constant: 10.y).isActive = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        view.addSubview(stackView)
        stackView.addAnchorToSuperview(centeredVertically: 0,centeredHorizontally: 0)
        
        imageSmile.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageSmile)
        imageSmile.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33).isActive = true
        imageSmile.heightAnchor.constraint(equalTo: imageSmile.widthAnchor, multiplier: 1.1).isActive = true
       
        
        imageBlink.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageBlink)
        imageBlink.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33).isActive = true
        imageBlink.heightAnchor.constraint(equalTo: imageBlink.widthAnchor, multiplier: 1.1).isActive = true
        
        return view
    }()
    
    
    
    let imageSmile : ExampleImage = {
        let imageRight = ExampleImage()
        imageRight.imageView.setImageFromBundle(FaceDetectionView.self, imageName: "smile")
        imageRight.label.text = "Smile"
        imageRight.blinkBorder()
        return imageRight
    }()
    let imageBlink : ExampleImage = {
        let imageRight = ExampleImage()
        imageRight.imageView.setImageFromBundle(FaceDetectionView.self, imageName: "blink")
        imageRight.label.text = "Blink"
        return imageRight
    }()
    
    lazy var preview: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let indicatorView : IndicatorView = {
        let view = IndicatorView()
      
        return view
    }()
    
}







