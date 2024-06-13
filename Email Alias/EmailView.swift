//
//  EmailView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI
import SwiftData

struct EmailView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var registered: Bool
    
    @Query(sort: \Email.privateComment, animation: .default) private var emails: [Email]
    @State private var search = ""
    
    @State private var comment = ""
    
    @State private var showReloadAlert = false
    @State private var showAddAlert = false
    
    #if os(macOS)
    @State private var reloading = false
    #endif
    
    var body: some View {
        NavigationSplitView {
            EmailList(search: search)
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
                            .symbolEffect(.rotate, options: .nonRepeating, value: reloading)
                    }
                    .keyboardShortcut(KeyEquivalent("R"), modifiers: .command)
                    #else
                    EditButton()
                    #endif
                    NavigationLink {
                        AddView(emails: emails, addEmail: addEmail(address:comment:additionalGoto:))
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
    
    private func reload() async {
        if !API.testMode {
            #if os(macOS)
            reloading.toggle()
            #endif
            do {
                let emails = try await API.getEmails()
                try modelContext.save(emails: emails)
            }
            catch {
                showReloadAlert = true
            }
        }
    }
    
    private func addEmail(address: String, comment: String, additionalGoto: String) async -> Bool {
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
}

#Preview(traits: .sampleEmails) {
    @Previewable @State var registered = true
    EmailView(registered: $registered)
}

struct EmailList: View {
    let search: String
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext
    
    @Query private var emails: [Email]
    
    @State private var showDeleteConfirmAlert = false
    @State private var emailsToDelete: [Email]? = nil
    @State private var showDeleteAlert = false
    @State private var showCopyAlert = false
    @State private var showEditAlert = false
    
    init(search: String) {
        let search = search.lowercased()
        self.search = search
        self._emails = Query(filter: #Predicate<Email> { search.isEmpty || $0.address.localizedStandardContains(search) || $0.privateComment.localizedStandardContains(search) }, sort: \Email.privateComment, animation: .default)
    }
    
    var body: some View {
        List {
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
                        Button {
                            copyEmailToPasteboard(email)
                        } label: {
                            Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                                .accessibilityLabel(Text("Copy to clipboard"))
                        }
                        .buttonStyle(PlainButtonStyle())
                        Toggle(
                            "",
                            isOn: .init {
                                email.active
                            } set: { value in
                                email.active = value
                                Task {
                                    do {
                                        if !(try await API.update(email: email)) {
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
            }
#if !os(macOS)
            .onDelete { indexSet in
                emailsToDelete = indexSet.map { emails[$0] }
                showDeleteConfirmAlert = true
            }
#endif
        }
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
        .alert("Error at deleting the email", isPresented: $showDeleteAlert) {
            EmptyView()
        }
        .alert("Error at updating the email", isPresented: $showEditAlert) {
            EmptyView()
        }
        .toast(message: "Email copied to clipboard", isShowing: $showCopyAlert)
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
