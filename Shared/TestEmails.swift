//
//  TestEmails.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftData
import SwiftUI

@MainActor
func insertTestEmails(into modelContext: ModelContext) {
    let testEmails = [
        Email(id: 0, address: "vAcd8HJOj6h9Hfq9n8F0@example.com", privateComment: "Apple", goto: [API.testEmail]),
        Email(id: 1, address: "gQo5Nu.H7j774eh3mscM@example.com", privateComment: "Google", goto: [API.testEmail]),
        Email(id: 2, address: "FPOjzL0h86Qq9yTZ8Ix4@example.com", privateComment: "Netflix", goto: [API.testEmail]),
        Email(id: 3, address: "glELoo9GWGnpT0VIZujM@example.com", privateComment: "GitHub", goto: [API.testEmail]),
        Email(id: 4, address: "nI0Ok0Q8x9hNutIiFRAK@example.com", privateComment: "Facebook", goto: [API.testEmail]),
        Email(id: 5, address: "yugS_xb992eLm3jRlk3Z@example.com", privateComment: "Microsoft", goto: [API.testEmail]),
        Email(id: 6, address: "11iLJ6HK6jshFzqFOo6P@example.com", privateComment: "Amazon", goto: [API.testEmail])
    ]
    
    for email in testEmails {
        modelContext.insert(email)
    }
}

private struct SampleEmails: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Email.self, configurations: config)
        insertTestEmails(into: container.mainContext)
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleEmails: Self = .modifier(SampleEmails())
}
