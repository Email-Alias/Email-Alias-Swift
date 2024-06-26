//
//  EmailAliasWatchApp.swift
//  Email Alias Watch Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import WatchConnectivity
import SwiftData

private let container = try! ModelContainer(
    for: Email.self,
    migrationPlan: EmailsMigrationPlan.self,
    configurations: ModelConfiguration(for: Email.self, isStoredInMemoryOnly: false)
)

class AppDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    let session = WCSession.default
    
    func applicationDidFinishLaunching() {
        session.delegate = self
        session.activate()
    }
    
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        switch userInfo["type"] as? String {
        case "register":
            UserDefaults.standard.setValue(userInfo[.domain], forKey: .domain)
            UserDefaults.standard.setValue(userInfo[.email], forKey: .email)
            let _ = save(valueToKeychain: userInfo[.apiKey] as! String, withKey: .apiKey)
            
            Task {
                if await API.testMode {
                    UserDefaults.standard.set(7, forKey: .nextID)
                    await MainActor.run {
                        insertTestEmails(into: container.mainContext)
                    }
                }
                
                UserDefaults.standard.setValue(true, forKey: .registered)
            }
        case "logout":
            Task {
                do {
                    try await MainActor.run {
                        try container.mainContext.delete(model: Email.self)
                    }
                    UserDefaults.standard.removeObject(forKey: .domain)
                    UserDefaults.standard.removeObject(forKey: .email)
                    let _ = removeFromKeychain(withKey: .apiKey)
                    UserDefaults.standard.removeObject(forKey: .nextID)
                    UserDefaults.standard.setValue(false, forKey: .registered)
                }
                catch {}
            }
        case "settings":
            UserDefaults.standard.setValue(userInfo[.language], forKey: .language)
        case "clearCache":
            Task {
                await MainActor.run {
                    try? container.mainContext.delete(model: Email.self)
                }
            }
        default:
            break
        }
    }
}

@main
struct EmailAliasWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @AppStorage(.language) private var language: Language = .system
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .language(language)
        }
    }
}
