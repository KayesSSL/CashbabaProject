//
//  EasyLabel.swift
//  CBFaceDetection
//
//  Created by Mausum Nandy on 25/4/24.
//

import UIKit

class EasyLabel : UILabel{
    private init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(color:UIColor, font: UIFont.FontType,size:CGFloat) {
        self.init()
        textColor = color
        self.font = UIFont.easyMarchantsFont(font, ofSize: size)
    }
}

