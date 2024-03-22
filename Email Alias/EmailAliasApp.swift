//
//  EmailAliasApp.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI
import SwiftData

#if os(macOS)
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
#endif

@main
struct EmailAliasApp: App {    
    @AppStorage(.colorScheme, store: .shared) private var colorScheme: ColorScheme = .system
    @AppStorage(.language, store: .shared) private var language: Language = .system
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(iOS)
    init() {
        WatchCommunicator.shared.initialize()
    }
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme.systemTheme)
                .language(language)
        }
        .modelContainer(container)

        WindowGroup(for: Email.self) { email in
            Group {
                if let email = email.wrappedValue {
                    NavigationStack {
                        EmailDetailView(email: email)
                    }
                }
                else {
                    EmptyView()
                }
            }
            .preferredColorScheme(colorScheme.systemTheme)
            .language(language)
        }
        
        #if os(macOS)
        Settings {
            NavigationStack {
                SettingsView()
                    .preferredColorScheme(colorScheme.systemTheme)
                    .language(language)
                    .padding()
            }
            .modelContainer(container)
        }
        #endif
    }
}
