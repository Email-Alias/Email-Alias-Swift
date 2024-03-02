//
//  RegisterView.swift
//  Email Alias Watch Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI

struct RegisterView: View {
    var body: some View {
        NavigationStack {
            Text("You are not registered. Please register on the iOS App.")
                .multilineTextAlignment(.center)
                .navigationTitle("Register")
        }
    }
}

#Preview {
    RegisterView()
}
