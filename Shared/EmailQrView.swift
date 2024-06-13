//
//  EmailQRView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import SwiftData

struct EmailQRView: View {
    let email: Email
    
    var body: some View {
        Group {
            if let image = "mailto:\(email.address)".generateQRCode() {
                Image.native(image)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            else {
                Text("The qr code couldn't be created.")
            }
        }
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @Query var emails: [Email]
    NavigationStack {
        EmailQRView(email: emails.first!)
    }
}
