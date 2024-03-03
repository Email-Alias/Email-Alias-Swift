//
//  ColorExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 03.03.24.
//

import SwiftUI

extension Color {
    static var backgroundColor: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
}
