//
//  Email.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 07.02.24.
//

import SwiftData
import Foundation

enum EmailsSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Email.self]
    }

    @Model
    final class Email: Identifiable, Codable, Equatable {
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
        
        static func == (lhs: Email, rhs: Email) -> Bool {
            lhs.id == rhs.id &&
            lhs.address == rhs.address &&
            lhs.privateComment == rhs.privateComment &&
            lhs.goto == rhs.goto
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case address
            case privateComment
            case goto
        }
    }
}

enum EmailsSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Email.self]
    }

    @Model
    final class Email: Identifiable, Codable, Equatable {
        let id: Int
        let address: String
        let privateComment: String
        let goto: String
        var active: Bool = true
        
        init(id: Int, address: String, privateComment: String, goto: String, active: Bool = true) {
            self.id = id
            self.address = address
            self.privateComment = privateComment
            self.goto = goto
            self.active = active
        }
        
        convenience init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                id: container.decode(Int.self, forKey: .id),
                address: container.decode(String.self, forKey: .address),
                privateComment: container.decode(String?.self, forKey: .privateComment) ?? "",
                goto: container.decode(String.self, forKey: .goto),
                active: Bool(truncating: container.decode(Int.self, forKey: .active) as NSNumber)
            )
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(address, forKey: .address)
            try container.encode(privateComment, forKey: .privateComment)
            try container.encode(goto, forKey: .goto)
            try container.encode(active, forKey: .active)
        }
        
        static func == (lhs: Email, rhs: Email) -> Bool {
            lhs.id == rhs.id &&
            lhs.address == rhs.address &&
            lhs.privateComment == rhs.privateComment &&
            lhs.goto == rhs.goto &&
            lhs.active == rhs.active
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case address
            case privateComment
            case goto
            case active
        }
    }
}

enum EmailsSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Email.self]
    }

    @Model
    final class Email: Identifiable, Codable, Equatable {
        let id: Int
        let address: String
        let privateComment: String
        private var gotos: [String] = []
        var active: Bool = true
        
        var goto: [String] {
            get {
                gotos
            }
            set {
                gotos = newValue
            }
        }
        
        init(id: Int, address: String, privateComment: String, goto: [String], active: Bool = true) {
            self.id = id
            self.address = address
            self.privateComment = privateComment
            self.gotos = goto
            self.active = active
        }
        
        convenience init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                id: container.decode(Int.self, forKey: .id),
                address: container.decode(String.self, forKey: .address),
                privateComment: container.decode(String?.self, forKey: .privateComment) ?? "",
                goto: container.decode(String.self, forKey: .goto).split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }),
                active: Bool(truncating: container.decode(Int.self, forKey: .active) as NSNumber)
            )
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(address, forKey: .address)
            try container.encode(privateComment, forKey: .privateComment)
            try container.encode(goto.joined(separator: ","), forKey: .goto)
            try container.encode(active, forKey: .active)
        }
        
        static func == (lhs: Email, rhs: Email) -> Bool {
            lhs.id == rhs.id &&
            lhs.address == rhs.address &&
            lhs.privateComment == rhs.privateComment &&
            lhs.goto == rhs.goto &&
            lhs.active == rhs.active
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case address
            case privateComment
            case goto
            case active
        }
    }
}

enum EmailsMigrationPlan: SchemaMigrationPlan {
    private static var v2EmailsToMigrate: [EmailsSchemaV2.Email] = []
    
    static var schemas: [any VersionedSchema.Type] {
        [EmailsSchemaV1.self, EmailsSchemaV2.self, EmailsSchemaV3.self]
    }
    
    private static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: EmailsSchemaV1.self, toVersion: EmailsSchemaV2.self)
    private static let migrateV2toV3 = MigrationStage.custom(fromVersion: EmailsSchemaV2.self, toVersion: EmailsSchemaV3.self) { context in
        v2EmailsToMigrate = try context.fetch(FetchDescriptor<EmailsSchemaV2.Email>())
        try context.delete(model: EmailsSchemaV2.Email.self)
    } didMigrate: { context in
        for email in v2EmailsToMigrate {
            let emailV3 = EmailsSchemaV3.Email(id: email.id, address: email.address, privateComment: email.privateComment, goto: [email.goto], active: email.active)
            context.insert(emailV3)
        }
    }

    
    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3]
    }
}

typealias Email = EmailsSchemaV3.Email
