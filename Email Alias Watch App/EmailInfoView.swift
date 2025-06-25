//
//  EmailInfoView.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import SwiftData

struct EmailInfoView: View {
    let email: Email
    let qrView: EmailQRView
    
    var body: some View {
        VStack {
            Text("Email address:")
                .bold()
            Text(email.address)
                .multilineTextAlignment(.center)
            if let imageView = qrView.generateImageView() {
                qrView.generateShareLink(imageView)
                    .navigationTitle(email.privateComment)
                    .padding()
            }
        }
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @Query var emails: [Email] = []
    EmailInfoView(email: emails.first!, qrView: EmailQRView(email: emails.first!))
}
