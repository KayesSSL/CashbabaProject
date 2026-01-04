//
//  CBSDKLanguageHandler.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation
// MARK: Language Handler
public protocol CBSDKLanguageDelegate {
    func languageDidChange(to language: SDKLanguage)
}
public class CBSDKLanguageHandler {
    
    public static let sharedInstance = CBSDKLanguageHandler()
    private init(){}
    
  
    private var delegates: [CBSDKLanguageDelegate] = []
    
    
    /// To get currently active SDKLanguage
    /// - Returns: Currently active SDKLanguage
    public func getCurrentLanguage() -> SDKLanguage{
        if(UserDefaults.standard.dictionaryRepresentation().keys.contains(K.UserDefaultsKey.ActiveLanguageIndex)){
            return SDKLanguage(index: UserDefaults.standard.integer(forKey: K.UserDefaultsKey.ActiveLanguageIndex))
        }else{
            return .English
        }
    }
    
    
    
    /// To switch current Active SDKLanguge
    /// - Parameter language: Pass the SDKLanguage Case you wish to Switch To
    public func switchLanguage(to language: SDKLanguage){
        UserDefaults.standard.set(language.index, forKey: K.UserDefaultsKey.ActiveLanguageIndex)
        UserDefaults.standard.synchronize()
        delegates.forEach { delegate in
            delegate.languageDidChange(to: language)
        }
      
        
    }
  
    
    /// getLocalizedDigits
    /// - Parameter numbers: any number String e.g: "500","10.02","0.01"
    /// - Returns: Localised Number String
    public func getLocalizedDigits(_ numbers: String?) -> String? {
          var numbers = numbers
          let formatter = NumberFormatter()
          formatter.minimumIntegerDigits = 1
          formatter.minimumFractionDigits = 0
          formatter.maximumFractionDigits = 2
          formatter.locale = NSLocale(localeIdentifier: getCurrentLanguage().identifier) as Locale
          
          for i in 0..<10 {
              let num = NSNumber(value: i)
              numbers = numbers?.replacingOccurrences(of: num.stringValue, with: formatter.string(from: num) ?? "")
          }
          numbers = ((numbers?.count ?? 0) > 0) ? numbers : "0"
         
          return numbers
      }
    
    public func addDelegate(_ delegate:CBSDKLanguageDelegate)  {
        self.delegates.append(delegate)
    }
    
    public func getCampaignLabel() -> String{
        switch self.getCurrentLanguage() {
        case .Bangla:
            return ""//CBSDKManager.dataStore.gwProcessResponse?.campaignLabelBn ?? ""
        case .English:
            return ""//CBSDKManager.dataStore.gwProcessResponse?.campaignLabelEn ?? ""
        }
    }
    
    
}
public enum SDKLanguage{
    
    case English
    case Bangla
    
    init(index: Int){
        switch index {
        case 0:
            self = .English
        case 1:
            self = .Bangla
        default:
            self = .English
        }
    }
    
    var index: Int{
        switch self {
        case .English:
            return 0
        case .Bangla:
            return 1
        }
    }
    
    var identifier: String{
        switch self {
        case .English:
            return "en"
        case .Bangla:
            return "bn"
        }
    }
    
   
}
public extension String {
    func sslComLocalized() -> String {
        return CBSDKLanguageHandler.sharedInstance.getCurrentLanguage() == SDKLanguage.English ?  langs.first(where: {$0.key.lowercased() == self.lowercased()})?.english ?? self : langs.first(where: {$0.key.lowercased() == self.lowercased()})?.bangla ?? self
    }
}
