//
//  SDKError.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation
public protocol SDKErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

public struct SDKError: SDKErrorProtocol {
    public var title: String?
    public var code: Int
    private var _description: String

    public var errorDescription: String? { return _description }
    public var failureReason: String? { return _description }

    public init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }

    // Helper factories for common categories
    public static func network(_ description: String, code: Int = 1533) -> SDKError {
        SDKError(title: "BadNetworkError", description: description, code: code)
    }

    public static func badURL(_ description: String = "Bad URL", code: Int = 1531) -> SDKError {
        SDKError(title: "BadURL", description: description, code: code)
    }

    public static func decode(_ description: String, code: Int = 1532) -> SDKError {
        SDKError(title: "BadAPIResponse", description: description, code: code)
    }

    public static func unauthorized(_ description: String = "Unauthorized", code: Int = 401) -> SDKError {
        SDKError(title: "Unauthorized", description: description, code: code)
    }

    public static func server(_ description: String, code: Int = 444) -> SDKError {
        SDKError(title: "ServerError", description: description, code: code)
    }
}
