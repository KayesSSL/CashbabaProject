//
//  Data.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/26/25.
//
import Foundation
extension Data {
    mutating func appendString(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
