//
//  SettingsView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.02.24.
//

import SwiftUI
#if !os(macOS)
import InAppSettingsKit
#endif
import SwiftData

#if os(macOS)
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale
    
    @AppStorage(.colorScheme, store: .shared) private var colorScheme: ColorScheme = .system
    @AppStorage(.language, store: .shared) private var language: Language = .system
    
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
            Button("Source code") {
                openURL(URL(string: "https://github.com/Email-Alias/Email-Alias-Swift")!)
            }
            Button("Clear email cache") {
                try? modelContext.delete(model: Email.self)
            }
        }
        .navigationTitle("Settings")
    }
}
#else
private struct SettingsView: UIViewControllerRepresentable {
    nonisolated class Coordinator: IASKAbstractSettingsStore, IASKSettingsDelegate {
        private let modelContext: ModelContext
        nonisolated private var defaults: UserDefaults {
            get {
                UserDefaults(suiteName: "group.com.opdehipt.Email-Alias")!
            }
        }
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
        }

        func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {}
        
        @MainActor
        func settingsViewController(_ settingsViewController: IASKAppSettingsViewController, buttonTappedFor specifier: IASKSpecifier) {
            switch (specifier.key) {
            case "clear_email_cache":
                try? DataContainer.shared.container.mainContext.delete(model: Email.self)
                #if os(iOS)
                WatchCommunicator.shared.send(userInfo: ["type": "clearCache"])
                #endif
                break
            default:
                break
            }
        }
        
        override func object(forKey key: String) -> Any? {
            defaults.object(forKey: key)
        }
        
        override func setObject(_ value: Any, forKey key: String) {
            defaults.set(value, forKey: key)
        }
        
        override func removeObject(with specifier: IASKSpecifier) {
            if let key = specifier.key {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    @Environment(\.modelContext) private var modelContext

    func makeCoordinator() -> Coordinator {
        Coordinator(modelContext: modelContext)
    }

    func makeUIViewController(context: Context) -> IASKAppSettingsViewController {
        let iask = IASKAppSettingsViewController(style: .insetGrouped)
        iask.bundle = Bundle.main
        iask.settingsStore = context.coordinator
        iask.delegate = context.coordinator
        return iask
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
#endif

#if os(macOS)
struct SettingsButton: View {
    @Binding var showSettings: Bool

    var body: some View {
        SettingsLink {
            Label("Settings", systemImage: "gear")
        }
    }
}
#else
struct SettingsButton: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        Button {
            showSettings = true
        } label: {
            Label("Settings", systemImage: "gear")
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }
}
#endif

#Preview(traits: .sampleEmails) {
    SettingsView()
}

