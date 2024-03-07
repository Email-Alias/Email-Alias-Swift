//
//  API.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import Foundation

struct API {
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
    
    static func getEmails() async throws -> [Email] {
        let goto = UserDefaults.standard.string(forKey: .email)!
        let req = baseReq(url: "get/alias/all")
        let (res, _) = try await URLSession.shared.data(for: req)
        return try decoder.decode([Email].self, from: res).filter { $0.goto == goto && !$0.privateComment.isEmpty }
    }
    
    static func addEmail(emails: [Email], address: String, privateComment: String) async throws -> Bool {
        let goto = UserDefaults.standard.string(forKey: .email)!
        let email = EmailReq(active: true, sogoVisible: false, address: address, goto: goto, privateComment: privateComment)
        var req = baseReq(url: "add/alias")
        req.httpMethod = "POST"
        req.httpBody = try encoder.encode(email)
        return try await send(basicRequest: req)
    }
    
    static func deleteEmails(emails: [Email]) async throws -> Bool {
        let ids = emails.map { $0.id }
        var req = baseReq(url: "delete/alias")
        req.httpBody = try encoder.encode(ids)
        req.httpMethod = "POST"
        return try await send(basicRequest: req)
    }
    
    private static func send(basicRequest req: URLRequest) async throws -> Bool {
        let (res, _) = try await URLSession.shared.data(for: req)
        let jsonRes = try decoder.decode([Result].self, from: res)
        return jsonRes.allSatisfy { $0.type == "success" }
    }
}

private struct EmailReq: Codable {
    let active: Bool
    let sogoVisible: Bool
    let address: String
    let goto: String
    let privateComment: String
}

struct Result: Decodable {
    let type: String
}
