//
//  LanguageExtension.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 27.02.24.
//

import SwiftUI

extension Language {
    var name: LocalizedStringKey {
        switch self {
        case .system:
            "System"
        case .english:
            "English"
        case .german:
            "German"
        }
    }
}
