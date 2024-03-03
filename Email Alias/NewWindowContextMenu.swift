//
//  NewWindowContextMenu.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 26.02.24.
//

import SwiftUI

extension View {
    func newWindowContextMenu<MenuItems>(_ action: @escaping () -> (), @ViewBuilder additionalMenuItems: () -> MenuItems) -> some View where MenuItems : View {
        Group {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.contextMenu {
                    additionalMenuItems()
                }
            }
            else {
                self.contextMenu {
                    Button {
                        action()
                    } label: {
                        Label("Open in new window", systemImage: "macwindow.badge.plus")
                    }
                }
                additionalMenuItems()
            }
            #else
            self.contextMenu {
                Button {
                    action()
                } label: {
                    Label("Open in new window", systemImage: "macwindow.badge.plus")
                }
                additionalMenuItems()
            }
            #endif
        }
    }
}
