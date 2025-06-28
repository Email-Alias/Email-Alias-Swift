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
                    .menuStateUpdate(menuState: menuState, value: true)
            }
            else {
                RegisterView(registered: $registered, showSettings: $showSettings)
                    .menuStateUpdate(menuState: menuState, value: false)
            }
        }
    }
}

private extension View {
    func menuStateUpdate(menuState: MenuState, value: Bool) -> some View {
        onAppear {
            menuState.addButtonEnabled = value
            menuState.reloadButtonEnabled = value
            menuState.clearCacheButtonEnabled = value
            menuState.logoutButtonEnabled = value
        }
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @State var showSettings = false

    ContentView(showSettings: $showSettings)
}
