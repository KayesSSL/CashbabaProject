//
//  CBSDKDataStore.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation

class CBSDKDataStore {
    private init(){
        
    }
    static let sharedInstance = CBSDKDataStore()
    
//    var integrationInformation: IntegrationInformation!
//    var emiInformation: EMIInformation?
//    var customerInformation: CustomerInformation?
//    var shipmentInformation: ShipmentInformation?
//    var productInformation: ProductInformation?
//    var additionalInformation: AdditionalInformation?
//    
//    var existingUser = false
//    var verifyCustomerResponse: VerifyOtpandLoginResponseModel?
//    var verifyLoginSession: VerifyLoginSessionResponseModel?
//    var availableEMIResponse: EMIListResponseModel?
//    var offerListResponse: OffersListResponseModel?
//    var gwProcessResponse: GWProcessResponseModel?
//    
//    var mobileBankingGW: [Desc]?
//    var internetBankingGW: [Desc]?
//    var otherCardsGW: [Desc]?
    
   
    var hasCard = false
//    var cardsArray: [CardsNoData]?
//    var wallets: [SavedWallet]?
    var hasAnAutoSelection: Bool?
//    var defaultTab: DefaultTab?
//    var autoSelectedGateways: [Desc]?
    
    
    var sessionKey: String? {
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.SessionKey)
        }set(newSessionKey){
            if newSessionKey == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.SessionKey)
                return
            }
            UserDefaults.standard.set(newSessionKey, forKey: K.UserDefaultsKey.SessionKey)
            UserDefaults.standard.synchronize()
        }
    }
    var registrationId: String?{
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.RegistrationId)
        }set(newRegistrationId){
            if newRegistrationId == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.RegistrationId)
                return
            }
            UserDefaults.standard.set(newRegistrationId, forKey: K.UserDefaultsKey.RegistrationId)
            UserDefaults.standard.synchronize()
        }
    }
    var encryptionKey: String?{
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.EncryptionKey)
        }set(newEncryptionKey){
            if newEncryptionKey == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.EncryptionKey)
                return
            }
            UserDefaults.standard.set(newEncryptionKey, forKey: K.UserDefaultsKey.EncryptionKey)
            UserDefaults.standard.synchronize()
        }
    }
    var customerPhone: String?{
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.CustomerPhoneNumber)
        }set(newCustomerPhone){
            if newCustomerPhone == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.CustomerPhoneNumber)
                return
            }
            UserDefaults.standard.set(newCustomerPhone, forKey: K.UserDefaultsKey.CustomerPhoneNumber)
            UserDefaults.standard.synchronize()
        }
    }
    var cutomerSession: String?{
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.CustomerSession)
        }set(newCustomerSession){
            if newCustomerSession == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.CustomerSession)
                return
            }
            UserDefaults.standard.set(newCustomerSession, forKey: K.UserDefaultsKey.CustomerSession)
            UserDefaults.standard.synchronize()
        }
    }
    var bnplStatus: String?{
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.BnplStatus)
        }set(newBnplStatus){
            if newBnplStatus == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.BnplStatus)
                return
            }
            UserDefaults.standard.set(newBnplStatus, forKey: K.UserDefaultsKey.BnplStatus)
            UserDefaults.standard.synchronize()
        }
    }
    
    var loginTrxSessionKey: String?{
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.LoginTrxSession)
        }set(newLoginTrxSessionKey){
            if newLoginTrxSessionKey == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.LoginTrxSession)
                return
            }
            UserDefaults.standard.set(newLoginTrxSessionKey, forKey: K.UserDefaultsKey.LoginTrxSession)
            UserDefaults.standard.synchronize()
        }
    }
    var customerName: String?{
        get{
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.CustomerName)
        }set(newLoginTrxSessionKey){
            if newLoginTrxSessionKey == nil{
                UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.CustomerName)
                return
            }
            UserDefaults.standard.set(newLoginTrxSessionKey, forKey: K.UserDefaultsKey.CustomerName)
            UserDefaults.standard.synchronize()
        }
    }
//    var paymentMethod: PaymentMethod?
//    var previousPaymentMethod: PaymentMethod?
//    var selectedOffer: DiscountList?
//    var selectedGateway: Desc?
  
    var isPayLaterBtnClicked = false

}
