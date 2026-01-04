//
//  KeyboardObserver.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation
import UIKit

class KeyboardObserver {
     
    init(for delegate : KeyboardObserverProtocol) {
        self.delegate = delegate
    }
    let delegate :KeyboardObserverProtocol!
    
    func add()  {
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue { //keyboardFrameBeginUserInfoKey
             
             delegate.keyboardWillShow(with: keyboardSize.height)
              
           }
       }
       
       @objc func keyboardWillHide(notification: NSNotification) {
        delegate.keybaordWillHide()
       }
}
protocol KeyboardObserverProtocol {
    func keyboardWillShow(with height: CGFloat )
    func keybaordWillHide()
}
