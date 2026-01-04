//
//  Constant.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation
import UIKit

struct K {
    private init(){}
    
    static let IS_DEV_BUILD = true
    static let IS_SERVER_COMMUNICATION_ENCRYPTED = false
    static let SDKVERSION = "1.0.0"
    struct NotificationKey {
        private init(){}
        
    }
    
    enum BaseURL{
        
        case SDKInit
        
        
        var Demo: String {
            switch self {
            case .SDKInit:
                return "https://psp.sslwireless.com/psp-app-merchant-sdk-api/api/"
            }
        }
        
        var Live: String {
            switch self {
            case .SDKInit:
                return "https://merchant-sdk-api.cash-baba.com/api/"
            }
        }
    }
    
    
    struct UserDefaultsKey {
        private init(){}
        static let ActiveLanguageIndex = "ActiveLanguageIndex"
        static let RegistrationId = "RegistrationId"
        static let EncryptionKey = "EncryptionKey"
        static let SessionKey = "SessionKey"
        static let CustomerPhoneNumber = "UserPhone"
        static let CustomerSession = "CustomerSession"
        static let BnplStatus = "BnplStatus"
        static let LoginTrxSession = "LoginTrxSession"
        static let PreviousRunMode = "PreviousRunMode"
        static let CustomerName = "CustomerName"
    }
   
    
    struct UI {
        private init(){}
        
        enum FontStyle {
            case black
            case blackItalic
            case bold
            case boldItalic
            case italic
            case light
            case lightItalic
            case medium
            case mediumItalic
            case regular
            case thin
            case thinItalic
        }
        
        
        static let BarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        
        static let MainScreenBounds = UIScreen.main.bounds
        //Base Design for Iphone 8 Plus
        static let factX = UIScreen.main.bounds.size.width/375
        static let factY = UIScreen.main.bounds.size.height/736
        //
        static var BottomSafeAreaInsetForNewerIphones: CGFloat {
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                let bottomPadding = window?.safeAreaInsets.bottom
                
                return bottomPadding ?? 0.0
            }else{
                return 0.0
            }
        }
        static func calculatedHeight(_ height:CGFloat)->CGFloat{
            return height * factY
        }
        
    }
    
    struct Messages {
        static let DefaultErrorMessage = "Something went wrong! Please try again."
        static let DefaultSuccessMessage = "Request Successful"
  
    }
    
    struct Misc {
        static let GOOGLE_MAP_API_KEY = ""
        static let DEVICE_TOKEN_KEY  = ""
        static let BinLength = 6
    }
    
    
    struct StaticText {
        private init(){}
        
        static let help_text_1 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        static let hello_text = ""
        static let ex_mobile_string: String = "Ex. 01XXXXXXXXX"
        static let ex_mobile_string_to_color: String = "01XXXXXXXXX"
        static let merchant_title: String = "SSLCommerz"
        
    }
}
