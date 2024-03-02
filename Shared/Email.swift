//
//  Email.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 07.02.24.
//

import SwiftData

@Model
final class Email: Identifiable, Codable {
    let id: Int
    let address: String
    let privateComment: String
    let goto: String
    
    init(id: Int, address: String, privateComment: String, goto: String) {
        self.id = id
        self.address = address
        self.privateComment = privateComment
        self.goto = goto
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(Int.self, forKey: .id),
            address: container.decode(String.self, forKey: .address),
            privateComment: container.decode(String?.self, forKey: .privateComment) ?? "",
            goto: container.decode(String.self, forKey: .goto)
        )
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(address, forKey: .address)
        try container.encode(privateComment, forKey: .privateComment)
        try container.encode(goto, forKey: .goto)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case address
        case privateComment
        case goto
    }
}
