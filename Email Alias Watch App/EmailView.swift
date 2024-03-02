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
    
    @Query(sort: \Email.id, animation: .default) private var emails: [Email]

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
                            await reload()
                        }
                    } label: {
                        Image(systemName: "arrow.circlepath")
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
        .alert("Do you really want to delete the email?", isPresented: $showDeleteConfirmAlert) {
            Button("Yes", role: .destructive) {
                if let emailsToDelete {
                    Task {
                        await deleteEmail(indicies: emailsToDelete)
                    }
                }
            }
            Button("No", role: .cancel) {}
        }
        .task {
            await reload()
        }
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
    
    private func addEmail(address: String, comment: String) async {
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
                    return
                }
                await reload()
            }
            catch {
                showAddAlert = true
            }
        }
    }
    
    private func deleteEmail(indicies: IndexSet) async {
        do {
            if !API.testMode {
                if !(try await API.deleteEmails(emails: indicies.map { emails[$0] })) {
                    showDeleteAlert = true
                    return
                }
            }
            for i in indicies {
                modelContext.delete(emails[i])
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
