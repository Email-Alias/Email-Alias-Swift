//
//  SettingsView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.02.24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale
    
    @AppStorage(.colorScheme, store: .shared) private var colorScheme = 0
    @AppStorage(.language, store: .shared) private var language = 0
    
    var body: some View {
        Form {
            Picker("Theme", selection: $colorScheme) {
                ForEach(ColorScheme.allCases, id: \.self) { scheme in
                    Text(scheme.name)
                        .tag(scheme.rawValue)
                }
            }
            Picker("Language", selection: $language) {
                ForEach(Language.allCases, id: \.self) { language in
                    Text(language.name)
                        .tag(language.rawValue)
                }
            }
            #if os(iOS)
            .onChange(of: language) {
                WatchCommunicator.shared.send(userInfo: [
                    "type": "settings",
                    .language: language,
                ])
            }
            #endif
            Button("Source code") {
                openURL(URL(string: "https://github.com/svenopdehipt/Email-Alias-Swift")!)
            }
            Button("Clear email cache") {
                try? modelContext.delete(model: Email.self)
                #if os(iOS)
                WatchCommunicator.shared.send(userInfo: ["type": "clearCache"])
                #endif
            }
        }
        .navigationTitle("Settings")
    }
}

#if !os(macOS)


struct SettingsButton: View {
    var body: some View {
        NavigationLink {
            SettingsView()
        } label: {
            Text("Settings")
                .opacity(0)
            Label("Settings", systemImage: "gear")
        }
        .keyboardShortcut(KeyEquivalent(","), modifiers: .command)
    }
}
#endif

#Preview {
    SettingsView()
}
