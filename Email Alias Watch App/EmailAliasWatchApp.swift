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
    configurations: ModelConfiguration(for: Email.self, isStoredInMemoryOnly: false)
)

class AppDelegate: NSObject, WKApplicationDelegate, WCSessionDelegate {
    let session = WCSession.default
    
    func applicationDidFinishLaunching() {
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        switch userInfo["type"] as? String {
        case "register":
            UserDefaults.standard.setValue(userInfo[.domain], forKey: .domain)
            UserDefaults.standard.setValue(userInfo[.email], forKey: .email)
            let _ = save(valueToKeychain: userInfo[.apiKey] as! String, withKey: .apiKey)
            
            if API.testMode {
                UserDefaults.standard.set(7, forKey: .nextID)
                insertTestEmails(into: container.mainContext)
            }
            
            UserDefaults.standard.setValue(true, forKey: .registered)
        case "logout":
            do {
                try container.mainContext.delete(model: Email.self)
                UserDefaults.standard.removeObject(forKey: .domain)
                UserDefaults.standard.removeObject(forKey: .email)
                let _ = removeFromKeychain(withKey: .apiKey)
                UserDefaults.standard.removeObject(forKey: .nextID)
                UserDefaults.standard.setValue(false, forKey: .registered)
            }
            catch {}
        case "settings":
            UserDefaults.standard.setValue(userInfo[.language], forKey: .language)
            break
        default:
            break
        }
    }
}

@main
struct EmailAliasWatchApp: App {
    @WKApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @AppStorage(.language) private var language = 0
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .language(language)
        }
    }
}
