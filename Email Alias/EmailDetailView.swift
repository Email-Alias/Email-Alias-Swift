//
//  EmailDetailView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 18.02.24.
//

import SwiftUI

struct EmailDetailView: View {
    let email: Email
    
    var body: some View {
        EmailQRView(email: email)
            .padding()
            .navigationTitle(email.privateComment)
    }
}

#Preview {
    NavigationStack {
        EmailDetailView(email: testEmails.first!)
    }
}
