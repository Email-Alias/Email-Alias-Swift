//
//  ContentView.swift
//  Email Alias Watch Watch App
//
//  Created by Sven Op de Hipt on 23.02.24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(.registered) private var registered = false
    
    var body: some View {
        TabView {
            if registered {
                EmailView()
            }
            else {
                RegisterView()
            }
            LicenseView()
        }
    }
}

#Preview {
    ContentView()
}
