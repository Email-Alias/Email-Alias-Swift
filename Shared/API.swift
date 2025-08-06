//
//  API.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import Foundation

nonisolated struct API {
    static let testDomain = "test.mail.opdehipt.com"
    static let testEmail = "test@example.com"
    
    static private let encoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    static private let decoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    static private var apiURL: URL {
        let domain = UserDefaults.standard.string(forKey: .domain)!
        return URL(string: "https://\(domain)/api/v1/")!
    }
    
    static private func baseReq(url: String) -> URLRequest {
        let apiKey = loadFromKeychain(withKey: .apiKey)!
        var req = URLRequest(url: apiURL.appending(path: url))
        req.addValue("application/json", forHTTPHeaderField: "accept")
        req.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }
    
    static var testMode: Bool {
        let domain = UserDefaults.standard.string(forKey: .domain)!
        return domain == testDomain
    }
    
    @concurrent
    static func getEmails() async throws -> [Email] {
        let goto = UserDefaults.standard.string(forKey: .email)!
        let req = baseReq(url: "get/alias/all")
        let (res, _) = try await URLSession.shared.data(for: req)
        return try decoder.decode([Email].self, from: res).filter { $0.goto.contains(goto) && !$0.privateComment.isEmpty }
    }
    
    @concurrent
    static func addEmail(emails: [Email], address: String, privateComment: String, additionalGotos: [String]) async throws -> Bool {
        let goto = UserDefaults.standard.string(forKey: .email)!
        let gotoString = (additionalGotos + [goto]).joined(separator: ",")
        let email = EmailReq(active: true, sogoVisible: false, address: address, goto: gotoString, privateComment: privateComment)
        var req = baseReq(url: "add/alias")
        req.httpMethod = "POST"
        req.httpBody = try encoder.encode(email)
        return try await send(basicRequest: req)
    }
    
    @concurrent
    static func deleteEmails(emails: [Email.ID]) async throws -> Bool {
        var req = baseReq(url: "delete/alias")
        req.httpMethod = "POST"
        req.httpBody = try encoder.encode(emails)
        return try await send(basicRequest: req)
    }
    
    @concurrent
    static func update(email: Email) async throws -> Bool {
        var req = baseReq(url: "edit/alias")
        req.httpMethod = "POST"
        req.httpBody = try encoder.encode(UpdateReq(items: [email.id], attr: email))
        return try await send(basicRequest: req)
    }
    
    @concurrent
    private static func send(basicRequest req: URLRequest) async throws -> Bool {
        let (res, _) = try await URLSession.shared.data(for: req)
        let jsonRes = try decoder.decode([Result].self, from: res)
        return jsonRes.allSatisfy { $0.type == "success" }
    }
}

private nonisolated struct EmailReq: Encodable {
    let active: Bool
    let sogoVisible: Bool
    let address: String
    let goto: String
    let privateComment: String
}

private nonisolated struct UpdateReq: Encodable {
    let items: [Int]
    let attr: Email
}

struct Result: Decodable {
    let type: String
}
