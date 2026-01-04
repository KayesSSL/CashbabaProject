//
//  CBSDKManager.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation
import UIKit

class CBSDKManager {
    //Base Design for Iphone 8 Plus
    
    static let factX = UIScreen.main.bounds.size.width/375
    
    static let factY = UIScreen.main.bounds.size.height/736
    
    //
    private init(){
        
    }
    static let sharedInstance = CBSDKManager()
    static let dataStore = CBSDKDataStore.sharedInstance
//    var design : Design?
//    var paymentDelegate: SSLCommerzPaymentDelegate?
//    var delegate: SSLComLanguageDelegate?
//    var cardPaymentDelegate: CardPaymentDelegate?
//    var mobileBankingPaymentDelegate: MobileBankingPaymentDelegate?
//    var otherCardPaymentDelegate: OtherCardsPaymentDelegate?
//    var colorStore: ColorStore = ColorStore()
    var mainNavigationController:UINavigationController?
    var isDev:Bool = false
   
    func delay(_ time:Double,completion : (()->Void)?){
        DispatchQueue.main.asyncAfter(deadline: .now()+time) {
            completion?()
        }
    }
//    internal var sdkDelegate:SSLCommerzDelegate?
//    static func calculatedHeight(_ height:CGFloat)->CGFloat{
//        return height * factY
//    }
  
    
    func logoutSession(){
        //let preferenceUtils = UserDefaults.standard
        //preferenceUtils.removeObject(forKey: K.UserDefaultsKey.CustomerPhoneNumber)
      //  preferenceUtils.removeObject(forKey: K.UserDefaultsKey.CustomerSession)
        
        
    }
    func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    func getIPAddress() -> String? {
        var address : String?

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                // wifi = ["en0"]
                // wired = ["en2", "en3", "en4"]
                // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                
                let name = String(cString: interface.ifa_name)
                if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
    
    func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    
    func date(toTimestamp dateStr: String?, dateFormate: String?, expectedDateFormate: String) -> String {
        let dateFormatter = DateFormatter()
        // This is important - we set our input date format to match our input string
        // if the format doesn't match you'll get nil from your string, so be careful
        dateFormatter.dateFormat = dateFormate//"yyyy-MM-dd"
        
        //`date(from:)` returns an optional so make sure you unwrap when using.
        let dateFromString: Date? = dateFormatter.date(from: dateStr ?? "")
        
        let formatter = DateFormatter()
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
//        if isBengali() == true {
//            formatter.locale = Locale(identifier: "bn")
//        }
        formatter.dateFormat = expectedDateFormate//"MMM dd, yyyy"
        guard dateFromString != nil else { return ""}
        
        //Using the dateFromString variable from before.
        let stringDate: String = formatter.string(from: dateFromString!)
        return stringDate
    }
}
