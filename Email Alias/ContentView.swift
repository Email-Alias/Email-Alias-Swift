//
//  ContentView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 01.02.24.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @Binding var showSettings: Bool
    
    @EnvironmentObject private var menuState: MenuState
    @AppStorage(.registered, store: .shared) private var registered = false
    
    var body: some View {
        Group {
            if registered {
                EmailView(registered: $registered, showSettings: $showSettings)
                    .onAppear {
                        menuState.reloadButtonEnabled = true
                        menuState.clearCacheButtonEnabled = true
                        menuState.logoutButtonEnabled = true
                    }
            }
            else {
                RegisterView(registered: $registered, showSettings: $showSettings)
                    .onAppear {
                        menuState.reloadButtonEnabled = false
                        menuState.clearCacheButtonEnabled = false
                        menuState.logoutButtonEnabled = false
                    }
            }
        }
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @State var showSettings = false

    ContentView(showSettings: $showSettings)
}
