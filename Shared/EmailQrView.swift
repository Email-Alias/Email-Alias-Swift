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
                VStack {
                    let imageView = Image(native: image)
                    imageView
                        .interpolation(.none)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    #if !os(watchOS)
                    ShareLink(item: imageView, preview: SharePreview("QR Code for \(email.address)", image: imageView)) {
                        Label("Share the qr code", systemImage: "square.and.arrow.up")
                    }
                    #endif
                }
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
