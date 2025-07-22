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
#elseif os(iOS)
private typealias Window = WindowGroup
#endif

@main
struct EmailAliasApp: App {    
    @AppStorage(.colorScheme, store: .shared) private var colorScheme: ColorScheme = .system
    #if os(macOS)
    @AppStorage(.language, store: .shared) private var language: Language = .system
    #endif
    @StateObject private var menuState = MenuState()
    @State private var showSettings = false
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(iOS)
    init() {
        WatchCommunicator.shared.initialize()
    }
    #endif

    var body: some Scene {
        let container = DataContainer.shared.container
        
        WindowGroup {
            ContentView(showSettings: $showSettings)
                .preferredColorScheme(colorScheme.systemTheme)
                #if os(macOS)
                .language(language)
                #endif
                .environmentObject(menuState)
        }
        .commands {
            AppMenu(showSettings: $showSettings, addButtonEnabled: $menuState.addButtonEnabled, reloadButtonEnabled: $menuState.reloadButtonEnabled, clearCacheButtonEnabled: $menuState.clearCacheButtonEnabled, logoutButtonEnabled: $menuState.logoutButtonEnabled)
        }
        .modelContainer(container)

        WindowGroup(id: "email_detail", for: Email.ID.self) { id in
            NavigationStack {
                EmailDetailView(id: id.wrappedValue)
            }
                .preferredColorScheme(colorScheme.systemTheme)
                #if os(macOS)
                .language(language)
                #endif
        }
        .modelContainer(container)
        
        Window("Add email", id: "add_email") {
            AddViewWindow()
                .environmentObject(menuState)
        }
        .modelContainer(container)
        
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
