//
//  ScrollableView.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/29/25.
//

import Foundation
import UIKit

class ScrollableView:UIView {
    let scrollView = UIScrollView()
    let contentView = UIView()
  
     init(axis: NSLayoutConstraint.Axis  = .vertical) {
        super.init(frame: .zero)
        self.addSubview(scrollView)
        scrollView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
        scrollView.addSubview(contentView)
        contentView.addAnchorToSuperview(leading: 0, trailing: 0, top: 0, bottom: 0)
         if(axis == .horizontal){
             contentView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
         }else{
             contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
         }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
