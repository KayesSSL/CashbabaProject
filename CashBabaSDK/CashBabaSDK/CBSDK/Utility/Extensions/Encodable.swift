//
//  Encodable.swift
//  Padma Bank
//
//  Created by Mausum Nandy on 4/28/21.
//  Copyright © 2021 SSL Wireless. All rights reserved.
//

import Foundation
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
