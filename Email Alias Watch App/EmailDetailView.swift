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
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            let qrView = EmailQRView(email: email)
            EmailInfoView(email: email, qrView: qrView)
                .navigationTitle(email.privateComment)
                .tag(0)
            qrView
                .tag(1)
        }
        .tabViewStyle(.carousel)
        .navigationBarBackButtonHidden(selectedTab == 1)
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @Query var emails: [Email] = []
    NavigationStack {
        EmailDetailView(email: emails.first!)
    }
}
