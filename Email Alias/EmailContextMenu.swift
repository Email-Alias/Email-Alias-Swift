//
//  NewWindowContextMenu.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 26.02.24.
//

import SwiftUI

extension View {
    func emailContextMenu(email: Email, openWindow: OpenWindowAction, deleteEmail: @escaping (Email) -> ()) -> some View {
        Group {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.contextMenu {
                    Button(role: .destructive) {
                        deleteEmail(email)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            else {
                self.contextMenu {
                    Button {
                        openWindow(id: "email_detail", value: email.id)
                    } label: {
                        Label("Open in new window", systemImage: "macwindow.badge.plus")
                    }
                    Button(role: .destructive) {
                        deleteEmail(email)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            #else
            self.contextMenu {
                Button {
                    openWindow(id: "email_detail", value: email.id)
                } label: {
                    Label("Open in new window", systemImage: "macwindow.badge.plus")
                }
                Button(role: .destructive) {
                    deleteEmail(email)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            #endif
        }
    }
}
