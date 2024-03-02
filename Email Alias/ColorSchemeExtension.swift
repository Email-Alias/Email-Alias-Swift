//
//  ColorSchemeExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 27.02.24.
//

import SwiftUI

extension ColorScheme {
    var name: LocalizedStringKey {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }
}
