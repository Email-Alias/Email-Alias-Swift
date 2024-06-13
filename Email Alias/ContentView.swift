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
    
    var body: some View {
        Group {
            if registered {
                EmailView(registered: $registered)
            }
            else {
                RegisterView(registered: $registered)
            }
        }
    }
}

#Preview(traits: .sampleEmails) {
    ContentView()
}
