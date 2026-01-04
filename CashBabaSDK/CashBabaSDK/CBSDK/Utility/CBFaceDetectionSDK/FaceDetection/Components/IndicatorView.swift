//
//  IndicatorView.swift
//  CBFaceDetection
//
//  Created by Mausum Nandy on 26/4/24.
//

import UIKit

class IndicatorView: UIView {

    var step:Int? {
        
        
        didSet{
            switch step{
                
            case 1:
                partOne.backgroundColor = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
            case 2:
//                partOne.backgroundColor = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
                partTwo.backgroundColor = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)

            default:
                partOne.backgroundColor = UIColor(red: 0.72, green: 0.73, blue: 0.76, alpha: 1)
                partTwo.backgroundColor = UIColor(red: 0.72, green: 0.73, blue: 0.76, alpha: 1)
              
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(partOne)
        partOne.addAnchorToSuperview(leading: 0,top: 0,bottom: 0,widthMutiplier: 0.49)
        addSubview(partTwo)
        partTwo.addAnchorToSuperview(trailing: 0,top: 0, bottom: 0,widthMutiplier: 0.49)
        
    
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    lazy var partOne : UIView = {
        let partOne = UIView()
        partOne.backgroundColor = UIColor(red: 0.72, green: 0.73, blue: 0.76, alpha: 1)
        
        return partOne
    }()
    let partTwo: UIView = {
        let partTwo = UIView()
        partTwo.backgroundColor = UIColor(red: 0.72, green: 0.73, blue: 0.76, alpha: 1)
       
        return partTwo
    }()
    
   
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
    
        
    }
}
