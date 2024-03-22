//
//  ColorScheme.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.02.24.
//

import SwiftUI

enum ColorScheme: Int, CaseIterable {
    case system = 0
    case light
    case dark
    
    var systemTheme: SwiftUI.ColorScheme? {
        switch self {
        case .system:
            .none
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}
