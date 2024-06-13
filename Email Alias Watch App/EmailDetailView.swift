//
//  EmailDetailView.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import SwiftData

struct EmailDetailView: View {
    let email: Email
    
    var body: some View {
        TabView {
            EmailQRView(email: email)
            EmailInfoView(email: email)
        }
        .tabViewStyle(.carousel)
        .navigationTitle(email.privateComment)
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @Query var emails: [Email] = []
    NavigationStack {
        EmailDetailView(email: emails.first!)
    }
}
