//
//  EmailHelper.swift
//  Email Alias
//
//  Created by Sven on 14.06.25.
//

import SwiftData
import SwiftUI

@MainActor
func addEmail(emails: [Email], modelContext: ModelContext, address: String, comment: String, additionalGoto: String, showAddAlert: @escaping () -> (), showCopyAlert: @escaping () -> (), showReloadAlert: @escaping () -> ()) async -> Bool {
    if API.testMode {
        let goto = UserDefaults.standard.string(forKey: .email)!
        let nextID = UserDefaults.standard.integer(forKey: .nextID)
        let gotos: [String]
        if additionalGoto.isEmpty {
            gotos = [goto]
        }
        else {
            gotos = additionalGoto.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) + [goto]
        }
        let email = Email(id: nextID, address: address, privateComment: comment, goto: gotos)
        modelContext.insert(email)
        UserDefaults.standard.set(nextID &+ 1, forKey: .nextID)
        copyEmailToPasteboard(email.address, showCopyAlert: showCopyAlert)
        return true
    }
    else {
        return await Task {
            do {
                if !(try await API.addEmail(emails: emails, address: address, privateComment: comment, additionalGotos: additionalGoto.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }))) {
                    return false
                }
                await reload(modelContext: modelContext, showReloadAlert: showReloadAlert)
                copyEmailToPasteboard(address, showCopyAlert: showCopyAlert)
            }
            catch {
                showAddAlert()
            }
            return true
        }.value
    }
}

@MainActor
func copyEmailToPasteboard(_ email: String, showCopyAlert: () -> ()) {
    #if os(macOS)
    NSPasteboard.general.declareTypes([.string], owner: nil)
    NSPasteboard.general.setString(email, forType: .string)
    #else
    UIPasteboard.general.string = email
    #endif
    showCopyAlert()
}

@MainActor
func reload(modelContext: ModelContext, showReloadAlert: () -> ()) async {
    if !API.testMode {
        do {
            let emails = try await API.getEmails()
            try modelContext.save(emails: emails)
        }
        catch {
            showReloadAlert()
        }
    }
}
