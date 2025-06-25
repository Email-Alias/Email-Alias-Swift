//
//  Menu.swift
//  Email Alias
//
//  Created by Sven on 14.06.25.
//

import SwiftUI
import SwiftData

class MenuState: ObservableObject {
    @Published var addButtonEnabled = false
    @Published var reloadButtonEnabled = false
    @Published var clearCacheButtonEnabled = false
    @Published var logoutButtonEnabled = false
}

@MainActor
func logout(modelContext: ModelContext, dismissWindow: DismissWindowAction, setRegistered: () -> ()) {
    do {
        try modelContext.delete(model: Email.self)
        UserDefaults.standard.removeObject(forKey: .domain)
        UserDefaults.standard.removeObject(forKey: .email)
        let _ = removeFromKeychain(withKey: .apiKey)
        UserDefaults.standard.removeObject(forKey: .nextID)
        #if os(iOS)
        WatchCommunicator.shared.send(userInfo: [
            "type": "logout"
        ])
        #endif
        dismissWindow(id: "email_detail")
        dismissWindow(id: "add_email")
        setRegistered()
    }
    catch {}
}

struct AppMenu: Commands {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.modelContext) private var modelContext
    @FocusedValue(\.generateRandomAlias) private var generateRandomAlias
    @FocusedValue(\.searchEmail) private var searchEmail
    
    @Binding var showSettings: Bool
    @Binding var addButtonEnabled: Bool
    @Binding var reloadButtonEnabled: Bool
    @Binding var clearCacheButtonEnabled: Bool
    @Binding var logoutButtonEnabled: Bool
    
    var body: some Commands {
        #if os(iOS)
        CommandGroup(replacing: .appSettings) {
            Button("Settings") {
                showSettings = true
            }
            .keyboardShortcut(KeyEquivalent(","), modifiers: .command)
        }
        #endif
        CommandMenu("Emails") {
            Button("Add") {
                openWindow(id: "add_email")
            }
            .keyboardShortcut(KeyEquivalent("+"), modifiers: .command)
            .disabled(!addButtonEnabled)
            Button("Reload") {
                Task {
                    await reload(modelContext: modelContext) {}
                }
            }
            .keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
            .disabled(!reloadButtonEnabled)
            Button("Search email") {
                searchEmail?()
            }
            .keyboardShortcut(KeyEquivalent("F"), modifiers: .command)
            .disabled(searchEmail == nil)
            Button("Generate random alias") {
                generateRandomAlias?()
            }
            .keyboardShortcut(KeyEquivalent("R"), modifiers: [.command, .shift])
            .disabled(generateRandomAlias == nil)
            Button("Clear email cache") {
                try? modelContext.delete(model: Email.self)
            }
            .keyboardShortcut(KeyEquivalent("C"), modifiers: [.command, .shift])
            .disabled(!clearCacheButtonEnabled)
        }
        CommandMenu("Account") {
            Button("Logout") {
                logout(modelContext: modelContext, dismissWindow: dismissWindow) {
                    UserDefaults.shared.set(false, forKey: .registered)
                }
            }
            .keyboardShortcut(KeyEquivalent("L"), modifiers: .command)
            .disabled(!logoutButtonEnabled)
        }
    }
}

struct RandomAliasActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

struct SearchActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var generateRandomAlias: RandomAliasActionKey.Value? {
        get { self[RandomAliasActionKey.self] }
        set { self[RandomAliasActionKey.self] = newValue }
    }

    var searchEmail: SearchActionKey.Value? {
        get { self[SearchActionKey.self] }
        set { self[SearchActionKey.self] = newValue }
    }
}
