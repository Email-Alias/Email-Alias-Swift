//
//  EmailAliasWatchApp.swift
//  Email Alias Watch Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import WatchConnectivity
import SwiftData

class AppDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    let context = DataContainer.shared.container.mainContext
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
                        insertTestEmails(into: context)
                    }
                }
                
                UserDefaults.standard.setValue(true, forKey: .registered)
            }
        case "logout":
            Task {
                do {
                    try await MainActor.run {
                        try context.delete(model: Email.self)
                    }
                    UserDefaults.standard.removeObject(forKey: .domain)
                    UserDefaults.standard.removeObject(forKey: .email)
                    let _ = removeFromKeychain(withKey: .apiKey)
                    UserDefaults.standard.removeObject(forKey: .nextID)
                    UserDefaults.standard.setValue(false, forKey: .registered)
                }
                catch {}
            }
        case "clearCache":
            Task {
                await MainActor.run {
                    try? context.delete(model: Email.self)
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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(DataContainer.shared.container)
        }
    }
}
