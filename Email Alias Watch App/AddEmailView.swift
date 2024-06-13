//
//  AddView.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import SwiftData

struct AddView: View {
    let emails: [Email]
    let addEmail: (String, String) async -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage(.email) private var email = ""
    
    @State private var comment = ""
    @State private var showFormAlert = false
    
    var body: some View {
        VStack {
            TextField("Description", text: $comment)
                .autocorrectionDisabled()
            Spacer()
                .frame(height: 20)
            Button {
                if comment.isEmpty {
                    showFormAlert = true
                    return
                }
                
                Task {
                    guard let domain = email.split(separator: "@").last else {
                        return
                    }
                    
                    var alias: String
                    repeat {
                        alias = String.random(length: 20)
                    }
                    while emails.contains { $0.address == "\(alias)@\(domain)" }
                    
                    await addEmail("\(alias)@\(domain)", comment)
                    dismiss()
                    comment = ""
                }
            } label: {
                Text("Add email")
            }
        }
        .alert("Description shouldn't be empty", isPresented: $showFormAlert) {
            EmptyView()
        }
        .padding()
        .navigationTitle("Add email")
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @Query var emails: [Email] = []
    NavigationStack {
        AddView(emails: emails) { _, _ in }
    }
}
