//
//  Dictionary.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/26/25.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func percentEscaped() -> String? {
        map { key, value in
            let k = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let v = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(value)"
            return "\(k)=\(v)"
        }.joined(separator: "&")
    }
}
