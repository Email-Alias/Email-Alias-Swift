//
//  EmailView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI
import SwiftData

struct AddEmailButton: View {
    let emails: [Email]
    
    @Binding var showReloadAlert: Bool
    @Binding var showAddAlert: Bool
    @Binding var showCopyAlert: Bool

    var body: some View {
        #if os(macOS)
        AddEmailButtonWindow()
        #elseif os(iOS)
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                AddEmailButtonLocal(emails: emails, showReloadAlert: $showReloadAlert, showAddAlert: $showAddAlert, showCopyAlert: $showCopyAlert)
            }
            else {
                AddEmailButtonWindow()
            }
        }
        #else
        AddEmailButtonLocal(emails: emails, showReloadAlert: $showReloadAlert, showAddAlert: $showAddAlert, showCopyAlert: $showCopyAlert)
        #endif
    }
}

#if os(macOS) || os(iOS)
struct AddEmailButtonWindow: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Button {
            openWindow(id: "add_email")
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
}
#endif

#if os(iOS) || os(visionOS)
struct AddEmailButtonLocal: View {
    @Environment(\.modelContext) private var modelContext
    
    let emails: [Email]
    
    @Binding var showReloadAlert: Bool
    @Binding var showAddAlert: Bool
    @Binding var showCopyAlert: Bool
    
    var body: some View {
        NavigationLink {
            AddView(emails: emails) { address, comment, additionalGoto in
                await addEmail(emails: emails, modelContext: modelContext, address: address, comment: comment, additionalGoto: additionalGoto) {
                    showAddAlert = true
                } showCopyAlert: {
                    showCopyAlert = true
                } showReloadAlert: {
                    showReloadAlert = true
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
}
#endif

struct LogoutButton: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Binding var registered: Bool

    var body: some View {
        Button {
            logout(modelContext: modelContext, dismissWindow: dismissWindow) {
                registered = false
            }
        } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
        }
    }
}

struct EmailView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var registered: Bool
    @Binding var showSettings: Bool
    
    @Query(sort: \Email.privateComment, animation: .default) private var emails: [Email]
    @State private var search = ""
    
    @State private var comment = ""
    
    @State private var showReloadAlert = false
    @State private var showAddAlert = false
    @State private var showCopyAlert = false
    
    #if os(macOS)
    @State private var reloading = false
    #endif
    
    @FocusState private var searchFocused
    
    var body: some View {
        NavigationSplitView {
            EmailList(search: search) { email in
                copyEmailToPasteboard(email) {
                    showCopyAlert = true
                }
            }
                .searchable(text: $search, prompt: "Search email")
                .searchFocused($searchFocused)
                .refreshable {
                    await reload(modelContext: modelContext) {
                        showReloadAlert = true
                    }
                }
                .navigationTitle("Emails")
                .toolbar {
                    #if !os(macOS)
                    EditButton()
                    #endif
                    SettingsButton(showSettings: $showSettings)
                    AddEmailButton(emails: emails, showReloadAlert: $showReloadAlert, showAddAlert: $showAddAlert, showCopyAlert: $showCopyAlert)
                    LogoutButton(registered: $registered)
                }
                .addViewAlerts(showReloadAlert: $showReloadAlert, showAddAlert: $showAddAlert, showCopyAlert: $showCopyAlert)
                .navigationSplitViewColumnWidth(ideal: 300)
        } detail: {
            Text("Click on an email to show a qr code with the address")
                .multilineTextAlignment(.center)
                .padding()
                .navigationTitle("Select email")
        }
        .focusedValue(\.searchEmail) {
            searchFocused.toggle()
        }
        .task {
            await reload(modelContext: modelContext) {
                showReloadAlert = true
            }
        }
    }
}

#Preview(traits: .sampleEmails) {
    @Previewable @State var registered = true
    @Previewable @State var showSettings = true
    EmailView(registered: $registered, showSettings: $showSettings)
}

struct EmailList: View {
    let search: String
    let copyEmailToPasteboard: (String) -> Void
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext
    
    @Query private var emails: [Email]
    
    @State private var showDeleteConfirmAlert = false
    @State private var emailsToDelete: [Email]? = nil
    @State private var showDeleteAlert = false
    @State private var showEditAlert = false
    
    init(search: String, copyEmailToPasteboard: @escaping (String) -> Void) {
        let search = search.lowercased()
        self.search = search
        self._emails = Query(filter: #Predicate<Email> { search.isEmpty || $0.address.localizedStandardContains(search) || $0.privateComment.localizedStandardContains(search) }, sort: \Email.privateComment, animation: .default)
        self.copyEmailToPasteboard = copyEmailToPasteboard
    }
    
    var body: some View {
        List {
            ForEach(emails) { email in
                NavigationLink {
                    EmailDetailView(id: email.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(email.privateComment)
                            Text(email.address)
                                .font(.caption)
                        }
                        Spacer()
                        Button {
                            copyEmailToPasteboard(email.address)
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
                        openWindow(id: "email_detail", value: email.id)
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
    }
    
    private func deleteEmails(emails: [Email]) async {
        Task {
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
}

