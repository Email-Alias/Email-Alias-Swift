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
    @AppStorage(.colorScheme, store: .shared) private var colorScheme = 0
    @AppStorage(.language, store: .shared) private var language = 0
    
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
                .colorScheme(colorScheme)
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
            .colorScheme(colorScheme)
            .language(language)
        }
        
        #if os(macOS)
        Settings {
            NavigationStack {
                SettingsView()
                    .colorScheme(colorScheme)
                    .language(language)
                    .padding()
            }
            .modelContainer(container)
        }
        #else
        WindowGroup(for: URL.self) { url in
            if let url = url.wrappedValue {
                PreviewController(url: url)
            }
            else {
                EmptyView()
            }
        }
        #endif
    }
}

private extension View {
    func colorScheme(_ scheme: Int) -> some View {
        #if os(visionOS)
        self
        #else
        Group {
            switch ColorScheme(rawValue: scheme) {
            case .system, nil:
                self
            case .light:
                self.preferredColorScheme(.light)
            case .dark:
                self.preferredColorScheme(.dark)
            }
        }
        #endif
    }
}
