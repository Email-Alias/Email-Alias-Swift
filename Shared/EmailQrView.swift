//
//  EmailQRView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI

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

#Preview {
    NavigationStack {
        EmailQRView(email: testEmails.first!)
    }
}
