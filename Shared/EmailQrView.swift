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
            if let imageView = generateImageView() {
                VStack {
                    imageView
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .padding()
                    #if !os(watchOS)
                    generateShareLink(imageView)
                    #endif
                }
                #if os(watchOS)
                .onAppear {
                    WKExtension.shared().isAutorotating = true
                }
                .onDisappear {
                    WKExtension.shared().isAutorotating = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(.container, edges: .all)
                #endif
            }
            else {
                Text("The qr code couldn't be created.")
            }
        }
    }
    
    func generateImageView() -> Image? {
        if let image = "mailto:\(email.address)".generateQRCode() {
            return Image(native: image)
        }
        return nil
    }
    
    func generateShareLink(_ imageView: Image) -> some View {
        return ShareLink(item: imageView, preview: SharePreview("QR Code for \(email.address)", image: imageView)) {
            Label("Share the qr code", systemImage: "square.and.arrow.up")
        }
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @Query var emails: [Email]
    NavigationStack {
        EmailQRView(email: emails.first!)
    }
}
