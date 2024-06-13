//
//  RegisterView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 01.02.24.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var registered: Bool

    @FocusState private var domainFocused
    @FocusState private var emailFocused
    @FocusState private var apiKeyFocused
    
    @State private var domain = ""
    @State private var email = ""
    @State private var apiKey = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                TextField("Domain", text: $domain)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                #endif
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .focused($domainFocused)
                    .onSubmit {
                        emailFocused = true
                    }
                Spacer().frame(height: 20)
                TextField("Email", text: $email)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                #endif
                    .textContentType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .focused($emailFocused)
                    .onSubmit {
                        apiKeyFocused = true
                    }
                Spacer().frame(height: 20)
                SecureField("API Key", text: $apiKey)
                #if !os(macOS)
                    .textInputAutocapitalization(.never)
                #endif
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .focused($apiKeyFocused)
                    .onSubmit {
                        register()
                    }
                Spacer().frame(height: 50)
                Button {
                    register()
                } label: {
                    Text("Continue")
                }
                Spacer()
                Text("OR")
                Spacer()
                Button("Test the app") {
                    registerForTest()
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: 800)
            .navigationTitle("Register")
            .toolbar {
                #if !os(macOS)
                SettingsButton()
                #endif
            }
            .onAppear {
                domainFocused = true
            }
        }
    }
    
    private func registerForTest() {
        UserDefaults.standard.set(7, forKey: .nextID)
        insertTestEmails(into: modelContext)
        register(domain: API.testDomain, email: API.testEmail, apiKey: "")
    }
    
    private func register() {
        register(domain: domain, email: email, apiKey: apiKey)
    }
    
    private func register(domain: String, email: String, apiKey: String) {
        UserDefaults.standard.setValue(domain, forKey: .domain)
        UserDefaults.standard.setValue(email, forKey: .email)
        let _ = save(valueToKeychain: apiKey, withKey: .apiKey)
        #if os(iOS)
        WatchCommunicator.shared.send(userInfo: [
            "type": "register",
            .domain: domain,
            .email: email,
            .apiKey: apiKey
        ])
        #endif
        registered = true
    }
}

#Preview {
    @Previewable @State var registered = false
    RegisterView(registered: $registered)
        .modelContainer(for: Email.self, inMemory: true)
}
