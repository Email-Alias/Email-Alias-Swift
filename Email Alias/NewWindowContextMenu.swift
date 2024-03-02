//
//  NewWindowContextMenu.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 26.02.24.
//

import SwiftUI

extension View {
    func newWindowContextMenu(_ action: @escaping () -> ()) -> some View {
        Group {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .phone {
                self
            }
            else {
                self.contextMenu {
                    Button {
                        action()
                    } label: {
                        Label("Open in new window", systemImage: "macwindow.badge.plus")
                    }
                }
            }
            #else
            self.contextMenu {
                Button {
                    action()
                } label: {
                    Label("Open in new window", systemImage: "macwindow.badge.plus")
                }
            }
            #endif
        }
    }
}
