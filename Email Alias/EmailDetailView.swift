//
//  EmailDetailView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 18.02.24.
//

import SwiftUI
import SwiftData

struct EmailDetailView: View {
    let id: Email.ID?
    
    @Environment(\.modelContext) private var context
    @AppStorage(.email) private var address: String = ""
    @State private var additionalGotos = ""
    @State private var email: Email?
    
    
    var body: some View {
        Group {
            if let email {
                VStack {
                    EmailQRView(email: email)
                    Spacer()
                        .frame(height: 20)
                    Text(email.address)
                    Spacer()
                        .frame(height: 20)
                    HStack {
                        Text("Additional destinations")
                            .font(.subheadline)
                        Spacer()
                    }
                    TextField("Additional destinations", text: $additionalGotos)
                    Spacer()
                        .frame(height: 50)
                    Button("Save") {
                        email.goto = [address] + additionalGotos.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        let email = email
                        Task {
                            let _ = try? await API.update(email: email)
                        }
                    }
                }
                .onAppear {
                    calculateGotos()
                }
                .onChange(of: email) {
                    calculateGotos()
                }
                .padding()
                .navigationTitle(email.privateComment)
            }
            else {
                ProgressView()
            }
        }
        .task {
            guard let id else { return }
            let descriptor = FetchDescriptor<Email>(
                predicate: #Predicate<Email> { $0.id == id }
            )
            if let first = (try? context.fetch(descriptor))?.first {
                email = first
            }
        }
    }
    
    private func calculateGotos() {
        var gotos: [String] = []
        for goto in email?.goto ?? [] {
            if goto != address {
                gotos.append(goto)
            }
        }
        additionalGotos = gotos.joined(separator: ",")
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @Query var emails: [Email]
    NavigationStack {
        EmailDetailView(id: emails.first?.id)
    }
}
