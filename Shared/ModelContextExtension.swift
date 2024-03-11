//
//  ModelContextExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 11.03.24.
//

import SwiftData

extension ModelContext {
    func save(emails: [Email]) throws {
        let cachedEmails = try fetch(FetchDescriptor<Email>())
        for email in emails {
            if let cachedEmail = cachedEmails.first(where: { $0.id == email.id }) {
                if cachedEmail.active != email.active {
                    delete(cachedEmail)
                    insert(email)
                }
            }
            else {
                insert(email)
            }
        }
        
        let deleteEmails = cachedEmails.filter { email in
            !emails.contains { email.id == $0.id }
        }
        for email in deleteEmails {
            delete(email)
        }
    }
}
