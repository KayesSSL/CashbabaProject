//
//  LanguageTexts.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation
public struct LanguageStruct {
    public let english:String
    public let bangla:String
    public let key:String
    
    public init(english: String, bangla: String, key: String) {
        self.english = english
        self.bangla = bangla
        self.key = key
    }
}
public let langs : [LanguageStruct] = [
    LanguageStruct(english: "OTP Verification", bangla: "ওটিপি যাচাই করুন", key: "otp_verification"),
    LanguageStruct(english: "Please Wait", bangla: "অনুগ্রহপূর্বক অপেক্ষা করুন", key: "please_wait_text"),
    LanguageStruct(english: "Support", bangla: "সাপোর্ট", key: "support"),
    LanguageStruct(english: "Send Code Again", bangla: "কোড আবার পাঠান", key: "send_code_again"),
    LanguageStruct(english: "I didn't receive a code", bangla: "আমি কোনো কোড পাইনি", key: "did_not_get_code"),
    LanguageStruct(english: "Resend", bangla: "আবার পাঠান", key: "resend"),
    LanguageStruct(english: "Verify", bangla: "যাচাই করুন", key: "verify"),
    LanguageStruct(english: "Welcome to", bangla: "স্বাগতম", key: "welcome_to"),
    LanguageStruct(english: "Setup Your 5 Digits Wallet PIN to Get Started", bangla: "৫ সংখ্যার ওয়ালেট পিন সেট-আপ করুন", key: "welcome_to_message"),
    LanguageStruct(english: "We’ve sent an SMS with OTP to %@", bangla: "%@ নম্বরে ওটিপিসহ একটি এসএমএস পাঠানো হয়েছে", key: "sent_sms_to_phone"),
    LanguageStruct(english: "Proceed", bangla: "এগিয়ে যান", key: "proceed"),
    LanguageStruct(english: "Verify phone number", bangla: "ফোন নম্বর যাচাই করুন", key: "verify_ph_no"),
    //PIN setup
    LanguageStruct(english: "Enter PIN", bangla: "পিন লিখুন", key: "enter_pin"),
    LanguageStruct(english: "PIN Setup", bangla: "পিন সেটআপ", key: "pin_setup"),
    LanguageStruct(english: "Set CashBaba Wallet PIN", bangla: "CashBaba Wallet এর পিন সেট করুন", key: "pin_setup_title"),
    LanguageStruct(english: "Please choose a secure 5-digit PIN for your CashBaba Wallet. Ensure that your PIN is easy for you to remember but difficult for others to guess", bangla: "আপনার CashBaba Wallet-এর জন্য একটি সুরক্ষিত ৫ সংখ্যার পিন নির্বাচন করুন। নিশ্চিত করুন যে আপনার পিনটি আপনি সহজে মনে রাখতে পারবেন।", key: "pin_setup_message"),
    LanguageStruct(english: "Submit", bangla: "জমা দিন", key: "submit"),
    LanguageStruct(english: "PIN Set up instructions:", bangla: "অ্যাকাউন্ট সুরক্ষিত রাখতে আপনি সহজে অনুমানযোগ্য পিন ব্যবহার করতে পারবেন না", key: "pin_instruction_title"),
    
    //Confirm PIN
    LanguageStruct(english: "Confirm PIN", bangla: "পিন নিশ্চিতকরণ", key: "confirm_pin"),
    LanguageStruct(english: "Enter CashBaba PIN", bangla: "CashBaba-পিন এখানে দিন", key: "enter_cashbaba_pin"),
    LanguageStruct(english: "Enter your CashBaba PIN to Confirm transaction", bangla: "CashBaba-পিন দিয়ে আপনার লেনদেন নিশ্চিত করুন", key: "enter_cashbaba_pin_confirm"),
    LanguageStruct(english: "Error!", bangla: "ভুল হয়েছে!", key: "error"),
    LanguageStruct(english: "Successful!", bangla: "সফল হয়েছে!", key: "successful"),
    LanguageStruct(english: "Close", bangla: "বন্ধ করুন", key: "close"),
    
    //Forgot PIN
    LanguageStruct(english: "Forgot PIN", bangla: "পিন ভুলে গেছেন", key: "forgot_pin"),
    LanguageStruct(english: "Enter Account Information", bangla: "অ্যাকাউন্ট তথ্য লিখুন", key: "enter_acc_info"),
    LanguageStruct(english: "Enter Account Information to setup new PIN", bangla: "নতুন পিন সেটআপ করতে অ্যাকাউন্ট তথ্য দিন", key: "enter_acc_info_to_set_pin"),
    LanguageStruct(english: "Last 4 Digits of NID", bangla: "জাতীয় পরিচয়পত্রের শেষ ৪ সংখ্যা", key: "last_4_digits"),
    LanguageStruct(english: "DOB", bangla: "জন্মতারিখ", key: "dob"),
    LanguageStruct(english: "Done", bangla: "ঠিক আছে", key: "done"),
    LanguageStruct(english: "Cancel", bangla: "বন্ধ করুন", key: "cancel"),
    
    // Change PIN
    LanguageStruct(english: "Change PIN", bangla: "পিন পরিবর্তন করুন", key: "change_pin"),
    LanguageStruct(english: "Change CashBaba Wallet PIN", bangla: "CashBaba Wallet এর পিন পরিবর্তন করুন", key: "change_pin_title"),
    LanguageStruct(english: "Please provide your old PIN and create a new one for your CashBaba Wallet. Make sure the new PIN is secure and follows the guidelines.", bangla: "আপনার পুরানো পিন প্রদান করুন এবং আপনার CashBaba Wallet-এর জন্য একটি নতুন পিন তৈরি করুন। নিশ্চিত করুন যে নতুন পিনটি সুরক্ষিত এবং নির্দেশনাগুলি অনুসরণ করে।", key: "change_pin_subtitle"),
    LanguageStruct(english: "Old PIN", bangla: "পুরাতন পিন", key: "old_pin"),
    LanguageStruct(english: "Enter PIN", bangla: "পিন লিখুন", key: "enter_pin"),
    LanguageStruct(english: "Confirm PIN", bangla: "পিন নিশ্চিত করুন", key: "confirm_pin"),
    LanguageStruct(english: "PIN Set up instructions:", bangla: "অ্যাকাউন্ট সুরক্ষিত রাখতে আপনি সহজে অনুমানযোগ্য পিন ব্যবহার করতে পারবেন না", key: "pin_change_instruction"),
    LanguageStruct(english: "Please smile, then blink your eyes", bangla: "দয়া করে হাসুন, এরপরে চোখের পলক ফেলুন", key: "blink_eyes"),
    LanguageStruct(english: "Back", bangla: "পিছনে", key: "back"),
    LanguageStruct(english: "Session expired", bangla: "সেশনের মেয়াদ শেষ", key: "session_expired")
    ]
