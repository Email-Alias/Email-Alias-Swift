//
//  AddViewWindow.swift
//  Email Alias
//
//  Created by Sven on 14.06.25.
//

import SwiftUI
import SwiftData

struct AddViewWindow: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Email.privateComment, animation: .default) private var emails: [Email]
    
    @State private var showAddAlert = false
    @State private var showReloadAlert = false

    var body: some View {
        AddView(emails: emails) { address, comment, additionalGoto in
            await addEmail(emails: emails, modelContext: modelContext, address: address, comment: comment, additionalGoto: additionalGoto) {
                showAddAlert = true
            } showCopyAlert: {
                NotificationCenter.default.post(name: .showCopyEmailToast, object: nil)
            } showReloadAlert: {
                showReloadAlert = true
            }
        }
        .addViewAlerts(showReloadAlert: $showReloadAlert, showAddAlert: $showAddAlert)
    }
}

extension Notification.Name {
    static let showCopyEmailToast = Notification.Name("showCopyEmailToast")
}
