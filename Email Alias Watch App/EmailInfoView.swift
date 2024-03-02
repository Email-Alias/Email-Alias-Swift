//
//  EmailInfoView.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI

struct EmailInfoView: View {
    let email: Email
    
    var body: some View {
        VStack {
            Text("Email address:")
                .bold()
            Text(email.address)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    EmailInfoView(email: testEmails.first!)
}
