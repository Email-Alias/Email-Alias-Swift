//
//  EmailView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI
import SwiftData

struct EmailView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext

    @Binding var registered: Bool
    
    @Query(sort: \Email.privateComment, animation: .default) private var emails: [Email]
    @State private var search = ""
    
    @State private var comment = ""
    
    @State private var showReloadAlert = false
    @State private var showAddAlert = false
    @State private var showDeleteAlert = false
    @State private var showCopyAlert = false
    @State private var showEditAlert = false
    @State private var showDeleteConfirmAlert = false
    @State private var emailsToDelete: [Email]? = nil
    
    var body: some View {
        NavigationSplitView {
            List {
                let emails = search.isEmpty ?
                    self.emails :
                self.emails.filter({ $0.address.lowercased().contains(search.lowercased()) || $0.privateComment.lowercased().contains(search.lowercased()) })
                ForEach(emails) { email in
                    NavigationLink {
                        EmailDetailView(email: email)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(email.privateComment)
                                Text(email.address)
                                    .font(.caption)
                            }
                            Spacer()
                            Toggle(
                                "",
                                isOn: .init {
                                    email.active
                                } set: { value in
                                    email.active = value
                                    Task {
                                        do {
                                            if !(try await API.updateActiveFor(email: email)) {
                                                showEditAlert = true
                                            }
                                        }
                                        catch {
                                            showEditAlert = true
                                        }
                                    }
                                }
                            )
                            .toggleStyle(CheckboxToggleStyle())
                            Button {
                                copyEmailToPasteboard(email)
                            } label: {
                                Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                                    .accessibilityLabel(Text("Copy to clipboard"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .newWindowContextMenu {
                            openWindow(value: email)
                        }
                    }
                    #if os(macOS)
                    .swipeActions {
                        Button {
                            emailsToDelete = [email]
                            showDeleteConfirmAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(Color.red)
                    }
                    #endif
                    .confirmationDialog("Do you really want to delete the email?", isPresented: $showDeleteConfirmAlert, titleVisibility: .visible) {
                        Button("Yes", role: .destructive) {
                            if let emailsToDelete {
                                Task {
                                    await deleteEmails(emails: emailsToDelete)
                                }
                            }
                        }
                        Button("No", role: .cancel) {}
                    }
                }
                #if !os(macOS)
                .onDelete { indexSet in
                    emailsToDelete = indexSet.map { emails[$0] }
                    showDeleteConfirmAlert = true
                }
                #endif
            }
            .searchable(text: $search, prompt: "Search email")
            .refreshable {
                await reload()
            }
            .navigationTitle("Emails")
            .toolbar {
                #if os(macOS)
                Button {
                    Task {
                        await reload()
                    }
                } label: {
                    Label("Reload", systemImage: "arrow.circlepath")
                }
                .keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
                #else
                EditButton()
                #endif
                NavigationLink {
                    AddView(emails: emails, addEmail: addEmail(address:comment:))
                } label: {
                    #if !os(macOS)
                    Text("Add")
                        .opacity(0)
                    #endif
                    Label("Add", systemImage: "plus")
                }
                .keyboardShortcut(KeyEquivalent("A"), modifiers: .command)
                #if !os(macOS)
                SettingsButton()
                #endif
                Button {
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
                        registered = false
                    }
                    catch {}
                } label: {
                    #if !os(macOS)
                    Text("Logout")
                        .opacity(0)
                    #endif
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .keyboardShortcut(KeyEquivalent("L"), modifiers: .command)
            }
            .alert("Error at loading the emails", isPresented: $showReloadAlert) {
                EmptyView()
            }
            .alert("Error at adding an email", isPresented: $showAddAlert) {
                EmptyView()
            }
            .alert("Error at deleting the email", isPresented: $showDeleteAlert) {
                EmptyView()
            }
            .alert("Error at updating the email", isPresented: $showEditAlert) {
                EmptyView()
            }
            .toast(message: "Email copied to clipboard", isShowing: $showCopyAlert)
            .navigationSplitViewColumnWidth(ideal: 300)
        } detail: {
            Text("Click on an email to show a qr code with the address")
                .multilineTextAlignment(.center)
                .padding()
                .navigationTitle("Select email")
        }
        .task {
            await reload()
        }
    }
    
    private func copyEmailToPasteboard(_ email: Email) {
        #if os(macOS)
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(email.address, forType: .string)
        #else
        UIPasteboard.general.string = email.address
        #endif
        showCopyAlert = true
    }
    
    private func reload() async {
        if !API.testMode {
            do {
                let emails = try await API.getEmails()
                for email in emails {
                    if !self.emails.contains(where: { $0.id == email.id }) {
                        modelContext.insert(email)
                    }
                }
                
                let deleteEmails = self.emails.filter { email in
                    !emails.contains { email.id == $0.id }
                }
                for email in deleteEmails {
                    modelContext.delete(email)
                }
            }
            catch {
                showReloadAlert = true
            }
        }
    }
    
    private func addEmail(address: String, comment: String) async -> Bool {
        if API.testMode {
            let goto = UserDefaults.standard.string(forKey: .email)!
            let nextID = UserDefaults.standard.integer(forKey: .nextID)
            let email = Email(id: nextID, address: address, privateComment: comment, goto: goto)
            modelContext.insert(email)
            UserDefaults.standard.set(nextID &+ 1, forKey: .nextID)
        }
        else {
            do {
                if (!(try await API.addEmail(emails: emails, address: address, privateComment: comment))) {
                    return false
                }
                await reload()
            }
            catch {
                showAddAlert = true
            }
        }
        return true
    }
    
    private func deleteEmails(emails: [Email]) async {
        do {
            if !API.testMode {
                if !(try await API.deleteEmails(emails: emails)) {
                    showDeleteAlert = true
                    return
                }
            }
            for email in emails {
                modelContext.delete(email)
            }
        }
        catch {
            showDeleteAlert = true
        }
    }
}

#Preview {
    EmailView(registered: .constant(true))
        .modelContainer(for: Email.self, inMemory: true) { result in
            if let context = try? result.get().mainContext {
                insertTestEmails(into: context)
            }
        }
}
