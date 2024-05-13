//
//  ContentView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 01.02.24.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @AppStorage(.registered, store: .shared) private var registered = false
    @AppStorage(.faceIdEnabled) private var faceIdEnabled = false
    
    @State private var blurView = false
    @State private var faceIdSuccess = false
    @State private var hasAppeared = false
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        Group {
            if (!faceIdEnabled || faceIdSuccess) {
                Group {
                    if registered {
                        EmailView(registered: $registered)
                    }
                    else {
                        RegisterView(registered: $registered)
                    }
                }
            }
            else {
                Button {
                    authWithFaceId()
                } label: {
                    Text("Login with TouchID/FaceID")
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background && faceIdEnabled {
                faceIdSuccess = false
            }
            else if oldPhase == .background && faceIdEnabled {
                authWithFaceId()
            }
        }
        .onAppear {
            if hasAppeared {
                return
            }
            hasAppeared = true
            faceIdSuccess = !faceIdEnabled
            if faceIdEnabled {
                authWithFaceId()
            }
        }
    }
    
    private func authWithFaceId() {
        Task {
            let context = LAContext()
            let success = try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "This app needs TouchID/FaceID to authorize the user.".localized)
            await MainActor.run {
                faceIdSuccess = success ?? false
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Email.self, inMemory: true) { result in
            if let context = try? result.get().mainContext {
                insertTestEmails(into: context)
            }
        }
}
