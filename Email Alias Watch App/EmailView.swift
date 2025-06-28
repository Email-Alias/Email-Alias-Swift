//
//  EmailView.swift
//  Email Alias Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI
import SwiftData

struct EmailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate { $0.active },
        sort: \Email.privateComment,
        animation: .default
    ) private var emails: [Email]

    @State private var reloading = false
    @State private var showReloadAlert = false
    @State private var showAddAlert = false
    @State private var showDeleteAlert = false
    @State private var showDeleteConfirmAlert = false
    @State private var emailsToDelete: IndexSet? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(emails) { email in
                    NavigationLink {
                        EmailDetailView(email: email)
                    } label: {
                        Text(email.privateComment)
                    }
                    .confirmationDialog("Do you really want to delete the email?", isPresented: $showDeleteConfirmAlert) {
                        Button("Yes", role: .destructive) {
                            if let emailsToDelete {
                                Task {
                                    await deleteEmail(indicies: emailsToDelete)
                                }
                            }
                        }
                        Button("No", role: .cancel) {}
                    }
                }
                .onDelete { indexSet in
                    emailsToDelete = indexSet
                    showDeleteConfirmAlert = true
                }
            }
            .toolbar {
                HStack {
                    Button {
                        Task {
                            reloading.toggle()
                            await reload()
                        }
                    } label: {
                        Image(systemName: "arrow.circlepath")
                            .symbolEffect(.rotate, options: .nonRepeating, value: reloading)
                            .accessibilityLabel(Text("Reload"))
                    }
                    NavigationLink {
                        AddView(emails: emails, addEmail: addEmail(address:comment:))
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel(Text("Add"))
                    }
                }
            }
            .navigationTitle("Emails")
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
        .task {
            await reload()
        }
    }
    
    private func reload() async {
        if !API.testMode {
            do {
                let emails = try await API.getEmails()
                try modelContext.save(emails: emails)
            }
            catch {
                showReloadAlert = true
            }
        }
    }
    
    private func addEmail(address: String, comment: String) async {
        if API.testMode {
            let goto = UserDefaults.standard.string(forKey: .email)!
            let nextID = UserDefaults.standard.integer(forKey: .nextID)
            let email = Email(id: nextID, address: address, privateComment: comment, goto: [goto])
            modelContext.insert(email)
            UserDefaults.standard.set(nextID &+ 1, forKey: .nextID)
        }
        else {
            do {
                let emails = self.emails
                try await Task {
                    if !(try await API.addEmail(emails: emails, address: address, privateComment: comment, additionalGotos: [])) {
                        return
                    }
                    await reload()
                }.value
            }
            catch {
                showAddAlert = true
            }
        }
    }
    
    private func deleteEmail(indicies: IndexSet) async {
        do {
            let emails = indicies.map { self.emails[$0].id }
            try modelContext.delete(model: Email.self, where: #Predicate { emails.contains($0.id) } )
            if !API.testMode {
                try await Task {
                    if !(try await API.deleteEmails(emails: emails)) {
                        showDeleteAlert = true
                        return
                    }
                }.value
            }
        }
        catch {
            showDeleteAlert = true
        }
    }
}

#Preview {
    EmailView()
        .modelContainer(for: Email.self, inMemory: true) { result in
            if let context = try? result.get().mainContext {
                insertTestEmails(into: context)
            }
        }
}
