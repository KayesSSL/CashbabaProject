//
//  APIHandler.swift
//  CBSDKTestApp
//
//  Created by Imrul Kayes on 10/12/25.
//

import Foundation
import SystemConfiguration

public enum CBHTTPMethod: String { case GET, POST }

public struct MultipartPart {
    public let name: String
    public let data: Data
    public let filename: String?
    public let mimeType: String?
    public init(name: String, data: Data, filename: String? = nil, mimeType: String? = nil) {
        self.name = name
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }
}

public final class APIHandler {
    public static var config = CashBabaConfig(environment: .demo, languageCode: "en")

    public static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { SCNetworkReachabilityCreateWithAddress(nil, $0) }
        }) else { return false }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) { return false }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    private static func defaultHeaders(requireAuth: Bool) -> [String: String] {
        var headers: [String: String] = [
            "lang": config.languageCode
        ]
        if let s = config.scope, !s.isEmpty { headers["scope"] = s }
        if let w = config.wToken, !w.isEmpty { headers["w-token"] = w }
        if requireAuth, let token = config.accessToken, !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

    public static func makeGetRequest(
        path: String,
        query: [String: Any]? = nil,
        requireAuth: Bool = true,
        onSuccess: @escaping (Data?) -> Void,
        onFailure: @escaping (String?) -> Void,
        onConnectionFailure: @escaping () -> Void
    ) {
        guard isConnectedToNetwork() else { return onConnectionFailure() }
        var urlString = config.environment.baseURL + path
        if let q = query, !q.isEmpty, let qs = q.percentEscaped() { urlString += "?\(qs)" }
        guard let url = URL(string: urlString) else { return onFailure("Bad URL") }
        var req = URLRequest(url: url)
        req.httpMethod = CBHTTPMethod.GET.rawValue
        defaultHeaders(requireAuth: requireAuth).forEach { req.setValue($1, forHTTPHeaderField: $0) }
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let e = error { return onFailure(e.localizedDescription) }
            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200, 201:
                if let data = data {
                        // Raw body as UTF-8
                        if let body = String(data: data, encoding: .utf8) {
                            print("[APIHandler] Success \(http.statusCode) body=\(body)")
                        } else {
                            print("[APIHandler] Success \(http.statusCode) received \(data.count) bytes (non-UTF8)")
                        }
                        // Optional: pretty-print JSON if applicable
                        if let obj = try? JSONSerialization.jsonObject(with: data),
                           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
                           let prettyStr = String(data: pretty, encoding: .utf8) {
                            print("[APIHandler] JSON pretty:\n\(prettyStr)")
                        }
                    } else {
                        print("[APIHandler] Success \(http.statusCode) with empty body")
                    }
                    onSuccess(data)
                case 401:
                    let msg = self.extractServerMessage(from: data, fallback: SDKError.unauthorized().errorDescription ?? "Unauthorized")
                    CashBaba.shared.closeSdkOnFailed(msg)
                    onFailure(msg)
                case 444, 500, 501:
                    let msg = self.extractServerMessage(from: data, fallback: "HTTP \(http.statusCode)")
                    CashBaba.shared.closeSdkOnFailed(msg)
                    onFailure(msg)
                default:
                    let msg = self.extractServerMessage(from: data, fallback: "HTTP \(http.statusCode)")
                    onFailure(msg)
                }
            } else {
                onSuccess(data)
            }
        }.resume()
    }

    public static func makePostForm(
        path: String,
        fields: [String: Any] = [:],
        requireAuth: Bool = true,
        onSuccess: @escaping (Data?) -> Void,
        onFailure: @escaping (String?) -> Void,
        onConnectionFailure: @escaping () -> Void
    ) {
        guard isConnectedToNetwork() else { return onConnectionFailure() }
        let urlString = config.environment.baseURL + path
        guard let url = URL(string: urlString) else { return onFailure("Bad URL") }
        var req = URLRequest(url: url)
        req.httpMethod = CBHTTPMethod.POST.rawValue
        var f = fields
        f["lang"] = config.languageCode
        req.httpBody = f.percentEscaped()?.data(using: .utf8)
        var headers = defaultHeaders(requireAuth: requireAuth)
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let e = error { return onFailure(e.localizedDescription) }
            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200, 201:
                    onSuccess(data)
                case 401:
                    let msg = self.extractServerMessage(from: data, fallback: SDKError.unauthorized().errorDescription ?? "Unauthorized")
                    CashBaba.shared.closeSdkOnFailed(msg)
                    onFailure(msg)
                case 444, 500, 501:
                    let msg = self.extractServerMessage(from: data, fallback: "HTTP \(http.statusCode)")
                    CashBaba.shared.closeSdkOnFailed(msg)
                    onFailure(msg)
                default:
                    let msg = self.extractServerMessage(from: data, fallback: "HTTP \(http.statusCode)")
                    onFailure(msg)
                }
            } else {
                onSuccess(data)
            }
        }.resume()
    }

    public static func makePostMultipart(
        path: String,
        parts: [String: Data],
        requireAuth: Bool = true,
        onSuccess: @escaping (Data?) -> Void,
        onFailure: @escaping (String?) -> Void,
        onConnectionFailure: @escaping () -> Void
    ) {
        guard isConnectedToNetwork() else { return onConnectionFailure() }
        let urlString = config.environment.baseURL + path
        guard let url = URL(string: urlString) else { return onFailure("Bad URL") }
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = CBHTTPMethod.POST.rawValue
        var headers = defaultHeaders(requireAuth: requireAuth)
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        var body = Data()
        for (name, data) in parts {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(name)\"\r\n")
            body.appendString("Content-Type: application/octet-stream\r\n\r\n")
            body.append(data)
            body.appendString("\r\n")
        }
        body.appendString("--\(boundary)--\r\n")
        req.httpBody = body
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let e = error { return onFailure(e.localizedDescription) }
            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200, 201:
                    onSuccess(data)
                case 401:
                    let msg = self.extractServerMessage(from: data, fallback: SDKError.unauthorized().errorDescription ?? "Unauthorized")
                    CashBaba.shared.closeSdkOnFailed(msg)
                    onFailure(msg)
                case 444, 500, 501:
                    let msg = self.extractServerMessage(from: data, fallback: "Request failed")
                    CashBaba.shared.closeSdkOnFailed(msg)
                    onFailure(msg)
                default:
                    let msg = self.extractServerMessage(from: data, fallback: "HTTP \(http.statusCode)")
                    onFailure(msg)
                }
            } else {
                onSuccess(data)
            }
        }.resume()
    }

    // New overload supporting filenames and MIME types per part
    public static func makePostMultipart(
        path: String,
        parts: [MultipartPart],
        requireAuth: Bool = true,
        onSuccess: @escaping (Data?) -> Void,
        onFailure: @escaping (String?) -> Void,
        onConnectionFailure: @escaping () -> Void
    ) {
        guard isConnectedToNetwork() else { return onConnectionFailure() }
        let urlString = config.environment.baseURL + path
        guard let url = URL(string: urlString) else { return onFailure("Bad URL") }
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = CBHTTPMethod.POST.rawValue
        var headers = defaultHeaders(requireAuth: requireAuth)
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        var body = Data()
        for part in parts {
            body.appendString("--\(boundary)\r\n")
            if let filename = part.filename, let mime = part.mimeType {
                body.appendString("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(filename)\"\r\n")
                body.appendString("Content-Type: \(mime)\r\n\r\n")
            } else {
                body.appendString("Content-Disposition: form-data; name=\"\(part.name)\"\r\n\r\n")
            }
            body.append(part.data)
            body.appendString("\r\n")
        }
        body.appendString("--\(boundary)--\r\n")
        req.httpBody = body
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let e = error { return onFailure(e.localizedDescription) }
            if let http = response as? HTTPURLResponse {
                switch http.statusCode {
                case 200:
                    onSuccess(data)
                case 401:
                    onFailure(SDKError.unauthorized().errorDescription)
                case 444:
                    onFailure(self.extractServerMessage(from: data, fallback: "Request failed"))
                default:
                    let msg = self.extractServerMessage(from: data, fallback: "HTTP \(http.statusCode)")
                    onFailure(msg)
                }
            } else {
                onSuccess(data)
            }
        }.resume()
    }

    // MARK: - Helpers
    private static func extractServerMessage(from data: Data?, fallback: String) -> String {
        guard let d = data else { return fallback }
        if let base = try? JSONDecoder().decode(BaseResponse.self, from: d),
           let msg = (base.messages?.first ?? base.details), !msg.isEmpty {
            return msg
        }
        return fallback
    }
}
