//
//  ContentView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 01.02.24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(.registered, store: .shared) private var registered = false
    
    var body: some View {
        if registered {
            EmailView(registered: $registered)
        }
        else {
            RegisterView(registered: $registered)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Email.self, inMemory: true) { result in
            if let context = try? result.get().mainContext {
                insertTestEmails(into: context)
            }
        }
}
